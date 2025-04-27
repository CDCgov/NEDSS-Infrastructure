#!/bin/bash

# Common library functions for all scripts

# system wide variables, should source this file first then 
# override on a per-script basis
RELEASE_VER=v7.9.1.1
INFRA_VER=v1.2.33
HELM_VER=v7.9.1.1
INSTALL_DIR=nbs_install
DEFAULTS_FILE="`pwd`/nbs_defaults.sh"
#DEFAULTS_FILE="${DEFAULTS_FILE:-`pwd`/nbs_defaults.sh}"
DEBUG=0
NOOP=0
DEBUG_MODE=0
STEP_MODE=0
TEST_MODE=0

log() {
    echo "[INFO] $*"
}

#########################################################
# combine the next three
debug() {
    if [ "${DEBUG:-0}" -eq 1 ]; then
        echo "[DEBUG] $*"
    fi
}
function debug_message() {
    if [[ $DEBUG -eq 1 ]]; then
        echo "DEBUG: $1"
    fi
}
log_debug() {
    [[ $DEBUG_MODE -eq 1 ]] && echo "DEBUG: $*"
}
#########################################################

debug_prompt() {
    if [ "$DEBUG" -eq 1 ]; then
        echo "[DEBUG] $1"
        read -p "Press enter to continue..."
    fi
}

#########################################################
# combine next two functions
function pause_step() {
    if [[ $STEP -eq 1 ]]; then
        read -p "Press [Enter] to continue..."
    fi
}
# Function to pause for step mode
step_pause() {
    [[ $STEP_MODE -eq 1 ]] && read -p "Press [Enter] key to continue..."
}
#########################################################

escape_sed() {
    echo "$1" | sed -e 's/[\\/&]/\\\\&/g'
}

#########################################################
#
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
        echo "WARNING: Unresolved placeholder(s) found in $file:"
        grep -nE "$pattern" "$file"
        #exit 1
    fi
}

check_for_examples() {
    local file="$1"
    local pattern='EXAMPLE'

    if grep -qE '^[[:space:]]*[^#[:space:]].*\b'"$pattern" "$file"; then
        echo "WARNING: Unresolved EXAMPLE(s) found in $file:"
        grep -nE '^[[:space:]]*[^#[:space:]].*\b'"$pattern" "$file"
        #exit 1
    fi
}

