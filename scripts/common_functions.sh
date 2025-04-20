#!/bin/bash

# Common library functions for all scripts

DEFAULTS_FILE="${DEFAULTS_FILE:-./nbs_defaults.sh}"

log() {
    echo "[INFO] $*"
}

debug() {
    if [ "${DEBUG:-0}" -eq 1 ]; then
        echo "[DEBUG] $*"
    fi
}

load_defaults() {
    if [ -f "$DEFAULTS_FILE" ]; then
        debug "Loading defaults from $DEFAULTS_FILE"
        source "$DEFAULTS_FILE"
    else
        debug "Defaults file $DEFAULTS_FILE not found."
    fi
}

update_defaults() {
    local var_name=$1
    local var_value=$2
    if grep -q "^${var_name}_DEFAULT=" "$DEFAULTS_FILE"; then
        sed -i "s?^${var_name}_DEFAULT=.*?${var_name}_DEFAULT=${var_value}?" "$DEFAULTS_FILE"
    else
        echo "${var_name}_DEFAULT=${var_value}" >> "$DEFAULTS_FILE"
    fi
}

resolve_secret() {
    local var_name="$1"
    local site_name="$2"
    local ssm_path="/nbs/${site_name}/${var_name}"
    local value=""

    eval "value=\${${var_name}_DEFAULT}"
    if [ -n "$value" ]; then
        echo "$value"
        return
    fi

    value=$(aws ssm get-parameter --name "$ssm_path" --with-decryption              --query 'Parameter.Value' --output text 2>/dev/null)
    if [ -n "$value" ]; then
        update_defaults "$var_name" "$value"
        echo "$value"
        return
    fi

    value=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 20)
    log "Generated new value for $var_name"

    aws ssm put-parameter --name "$ssm_path"         --type SecureString --value "$value"         --overwrite --tier Standard >/dev/null

    update_defaults "$var_name" "$value"
    echo "$value"
}

prompt_for_value() {
    local var_name="$1"
    local prompt="$2"
    local default_value="$3"
    local is_secret="$4"

    local input=""
    if [ "$is_secret" = "true" ]; then
        read -sp "$prompt [$default_value]: " input
        echo
    else
        read -p "$prompt [$default_value]: " input
    fi
    input="${input:-$default_value}"
    update_defaults "$var_name" "$input"
    echo "$input"
}

check_for_placeholders() {
    local file="$1"
    local pattern='<<[^<>]*>>'

    if grep -qE "$pattern" "$file"; then
        echo "❌ ERROR: Unresolved placeholder(s) found in $file:"
        grep -nE "$pattern" "$file"
        exit 1
    fi
}
