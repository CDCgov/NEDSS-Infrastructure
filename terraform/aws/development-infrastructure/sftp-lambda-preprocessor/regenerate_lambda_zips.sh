#!/bin/bash
# regenerate_lambda_zips.sh

set -e

LAMBDA_DIR="lambda"
BUILD_DIR="build"

declare -A LAMBDA_SCRIPTS=(
  ["lambda_split_csv.zip"]="lambda_split_csv.py"
  ["lambda_split_dat.zip"]="lambda_split_dat.py"
  ["lambda_split_obr.zip"]="lambda_split_obr.py"
)

mkdir -p "$BUILD_DIR"

for ZIP_NAME in "${!LAMBDA_SCRIPTS[@]}"; do
  SCRIPT_NAME="${LAMBDA_SCRIPTS[$ZIP_NAME]}"
  ZIP_PATH="${BUILD_DIR}/${ZIP_NAME}"

  if [[ ! -f "$LAMBDA_DIR/$SCRIPT_NAME" ]]; then
    echo "ERROR: $SCRIPT_NAME not found in $LAMBDA_DIR/"
    exit 1
  fi

  echo "Creating $ZIP_PATH from $LAMBDA_DIR/$SCRIPT_NAME"
  zip -j "$ZIP_PATH" "$LAMBDA_DIR/$SCRIPT_NAME"
done

echo "All Lambda zip packages have been regenerated in $BUILD_DIR/"

