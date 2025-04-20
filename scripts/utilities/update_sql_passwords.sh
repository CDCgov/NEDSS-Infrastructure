#!/bin/bash
# Updates a SQL file with site-specific values by resolving secrets from:
# 1. nbs_defaults.sh (if present)
# 2. AWS SSM Parameter Store
# 3. Generated if missing (then stored back in both)
# Produces a site-specific SQL file for customization.

DEFAULTS_FILE="nbs_defaults.sh"
SEARCH_REPLACE=0
SQL_FILE="01_nbssecuritylogins.sql"
SITE_NAME=""
NEW_FILES=()

# Usage info
usage() {
    echo "Usage: $0 [-s] [-f sql_file] [-n site_name]"
    echo "  -s              Perform search and replace"
    echo "  -f <sql_file>   SQL file to update (default: 01_nbssecuritylogins.sql)"
    echo "  -n <site_name>  Site name to customize filenames and parameter paths"
    exit 1
}

# Parse options
while getopts 'sf:n:' OPTION; do
    case "$OPTION" in
        s) SEARCH_REPLACE=1 ;;
        f) SQL_FILE="$OPTARG" ;;
        n) SITE_NAME="$OPTARG" ;;
        ?) usage ;;
    esac
done

# Check file exists
if [ ! -f "$SQL_FILE" ]; then
    echo "ERROR: SQL file $SQL_FILE not found."
    exit 1
fi

# Load previous defaults
if [ -f "$DEFAULTS_FILE" ]; then
    echo "Loading defaults from $DEFAULTS_FILE"
    source "$DEFAULTS_FILE"
else
    echo "ERROR: Defaults file $DEFAULTS_FILE not found."
    exit 1
fi

# Prompt for site if not set
if [ -z "$SITE_NAME" ]; then
    read -p "Enter site name [${SITE_NAME_DEFAULT}]: " SITE_NAME
    SITE_NAME=${SITE_NAME:-$SITE_NAME_DEFAULT}
fi

# --- Update defaults file ---
update_defaults() {
    local var_name=$1
    local var_value=$2
    if grep -q "^${var_name}_DEFAULT=" "$DEFAULTS_FILE"; then
        sed -i "s?^${var_name}_DEFAULT=.*?${var_name}_DEFAULT=${var_value}?" "$DEFAULTS_FILE"
    else
        echo "${var_name}_DEFAULT=${var_value}" >> "$DEFAULTS_FILE"
    fi
}

# --- Secret resolver with fallback ---
resolve_secret() {
    local var_name="$1"
    local ssm_path="/nbs/${SITE_NAME}/${var_name}"
    local value=""

    # 1. Check local defaults
    eval "value=\${${var_name}_DEFAULT}"
    if [ -n "$value" ]; then
        echo "$value"
        return
    fi

    # 2. Try AWS SSM
    value=$(aws ssm get-parameter --name "$ssm_path" --with-decryption \
             --query 'Parameter.Value' --output text 2>/dev/null)
    if [ -n "$value" ]; then
        update_defaults "$var_name" "$value"
        echo "$value"
        return
    fi

    # 3. Generate new if still missing (alphanumeric only, 20 chars)
    value=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 20)
    #value=$(openssl rand -base64 32 | cut -c1-32)
    echo "Generated new password for $var_name"

    # Save to SSM
    aws ssm put-parameter --name "$ssm_path" \
        --type SecureString --value "$value" \
        --overwrite --tier Standard >/dev/null

    # Save to defaults
    update_defaults "$var_name" "$value"
    echo "$value"
}

# Prepare new SQL filename
filename=$(basename -- "$SQL_FILE")
extension="${filename##*.}"
filename="${filename%.*}"
NEW_SQL_FILE="${filename}-${SITE_NAME}.${extension}"
cp -ip "$SQL_FILE" "$NEW_SQL_FILE" || exit 1
NEW_FILES+=("$NEW_SQL_FILE")

# Resolve all required values
DB_NAME=${DB_NAME_DEFAULT:-"NBS_${SITE_NAME}"}
DB_USER=${DB_USER_DEFAULT:-"${SITE_NAME}_USER"}
DB_USER_PASSWORD=$(resolve_secret "DB_USER_PASSWORD")
RDB_DB_USER_PASSWORD=$(resolve_secret "RDB_DB_USER_PASSWORD")
SRTE_DB_USER_PASSWORD=$(resolve_secret "SRTE_DB_USER_PASSWORD")
ODSE_DB_USER_PASSWORD=$(resolve_secret "ODSE_DB_USER_PASSWORD")
KC_DB_USER_PASSWORD=$(resolve_secret "KC_DB_USER_PASSWORD")
#NBS_AUTHUSER=$(resolve_secret "NBS_AUTHUSER")

# Apply replacements
if [ "$SEARCH_REPLACE" -eq 1 ]; then
    echo "Performing substitutions in $NEW_SQL_FILE..."

    sed -i "s/EXAMPLE_ENVIRONMENT/${SITE_NAME}/g" "$NEW_SQL_FILE"
    sed -i "s/EXAMPLE_DB_NAME/${DB_NAME}/g" "$NEW_SQL_FILE"
    sed -i "s/EXAMPLE_DB_USER/${DB_USER}/g" "$NEW_SQL_FILE"
    sed -i "s?EXAMPLE_DB_USER_PASSWORD?${DB_USER_PASSWORD}?g" "$NEW_SQL_FILE"
    sed -i "s?EXAMPLE_RDB_DB_USER_PASSWORD?${RDB_DB_USER_PASSWORD}?g" "$NEW_SQL_FILE"
    sed -i "s?EXAMPLE_SRTE_DB_USER_PASSWORD?${SRTE_DB_USER_PASSWORD}?g" "$NEW_SQL_FILE"
    sed -i "s?EXAMPLE_ODSE_DB_USER_PASSWORD?${ODSE_DB_USER_PASSWORD}?g" "$NEW_SQL_FILE"
    sed -i "s?EXAMPLE_KC_DB_USER_PASSWORD?${KC_DB_USER_PASSWORD}?g" "$NEW_SQL_FILE"
    echo "Substitution completed."
else
    echo "NOTE: Substitution skipped. Use -s flag to activate it."
fi

echo
echo "Output SQL file: $NEW_SQL_FILE"
