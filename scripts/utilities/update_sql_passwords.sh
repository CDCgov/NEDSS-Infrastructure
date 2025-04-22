#!/bin/bash

source "$(dirname "$0")/../common_functions.sh"

escape_sed() {
    echo "$1" | sed -e 's/[\\/&]/\\\\&/g'
}

DEFAULTS_FILE="`pwd`/nbs_defaults.sh"
SEARCH_REPLACE=0
SQL_FILE="01_nbssecuritylogins.sql"
SITE_NAME=""
NEW_FILES=()

# Parse options
while getopts 'sf:n:' OPTION; do
    case "$OPTION" in
        s) SEARCH_REPLACE=1 ;;
        f) SQL_FILE="$OPTARG" ;;
        n) SITE_NAME="$OPTARG" ;;
        ?) exit 1 ;;
    esac
done

if [ ! -f "$SQL_FILE" ]; then
    echo "ERROR: SQL file $SQL_FILE not found."
    exit 1
fi

load_defaults

if [ -z "$SITE_NAME" ]; then
    read -p "Enter site name [${SITE_NAME_DEFAULT}]: " SITE_NAME
    SITE_NAME=${SITE_NAME:-$SITE_NAME_DEFAULT}
fi

filename=$(basename -- "$SQL_FILE")
extension="${filename##*.}"
filename="${filename%.*}"
NEW_SQL_FILE="${filename}-${SITE_NAME}.${extension}"
cp -ip "$SQL_FILE" "$NEW_SQL_FILE" || exit 1
NEW_FILES+=("$NEW_SQL_FILE")

DB_NAME=${DB_NAME_DEFAULT:-"NBS_${SITE_NAME}"}
DB_USER=${DB_USER_DEFAULT:-"${SITE_NAME}_USER"}
DB_USER_PASSWORD=$(resolve_secret "DB_USER_PASSWORD" "$SITE_NAME")
RDB_DB_USER_PASSWORD=$(resolve_secret "RDB_DB_USER_PASSWORD" "$SITE_NAME")
SRTE_DB_USER_PASSWORD=$(resolve_secret "SRTE_DB_USER_PASSWORD" "$SITE_NAME")
ODSE_DB_USER_PASSWORD=$(resolve_secret "ODSE_DB_USER_PASSWORD" "$SITE_NAME")
KC_DB_USER_PASSWORD=$(resolve_secret "KC_DB_USER_PASSWORD" "$SITE_NAME")

if [ "$SEARCH_REPLACE" -eq 1 ]; then
    echo "Performing substitutions in $NEW_SQL_FILE..."
    sed -i "s|<<EXAMPLE_ENVIRONMENT>>|${SITE_NAME}|g" "$NEW_SQL_FILE"
    sed -i "s|<<EXAMPLE_DB_NAME>>|${DB_NAME}|g" "$NEW_SQL_FILE"
    sed -i "s|<<EXAMPLE_DB_USER>>|${DB_USER}|g" "$NEW_SQL_FILE"
    sed -i "s|<<EXAMPLE_DB_USER_PASSWORD>>|$(escape_sed "$DB_USER_PASSWORD")|g" "$NEW_SQL_FILE"
    sed -i "s|<<EXAMPLE_RDB_DB_USER_PASSWORD>>|$(escape_sed "$RDB_DB_USER_PASSWORD")|g" "$NEW_SQL_FILE"
    sed -i "s|<<EXAMPLE_SRTE_DB_USER_PASSWORD>>|$(escape_sed "$SRTE_DB_USER_PASSWORD")|g" "$NEW_SQL_FILE"
    sed -i "s|<<EXAMPLE_ODSE_DB_USER_PASSWORD>>|$(escape_sed "$ODSE_DB_USER_PASSWORD")|g" "$NEW_SQL_FILE"
    sed -i "s|<<EXAMPLE_KC_DB_USER_PASSWORD>>|$(escape_sed "$KC_DB_USER_PASSWORD")|g" "$NEW_SQL_FILE"
    echo "Substitution completed."
else
    echo "NOTE: Substitution skipped. Use -s flag to activate it."
fi

check_for_placeholders "$NEW_SQL_FILE"

echo
echo "Output SQL file: $NEW_SQL_FILE"
