#!/bin/bash
# regenerate_lambda_zips.sh
# Zips Lambda functions including their pip-installed dependencies from subdirs.

set -e # Exit immediately if a command exits with a non-zero status.

LAMBDA_PARENT_DIR="lambda"
BUILD_DIR="build"
CURRENT_DIR=$(pwd) # Get the absolute path of the current directory

# Define the Lambda subdirectories (these will also be the base for zip/py names)
LAMBDAS=(
  "lambda_split_csv"
  "lambda_split_dat"
  "lambda_split_obr"
)

# Ensure the build directory exists
mkdir -p "$BUILD_DIR"
echo "Build directory '$BUILD_DIR' ensured."

# Loop through each defined Lambda
for LAMBDA_NAME in "${LAMBDAS[@]}"; do
  LAMBDA_SUB_DIR="${LAMBDA_PARENT_DIR}/${LAMBDA_NAME}"
  SCRIPT_NAME="${LAMBDA_NAME}.py"
  SCRIPT_PATH="${LAMBDA_SUB_DIR}/${SCRIPT_NAME}"
  REQ_FILE="${LAMBDA_SUB_DIR}/requirements.txt"
  ZIP_NAME="${LAMBDA_NAME}.zip"
  ZIP_PATH="${CURRENT_DIR}/${BUILD_DIR}/${ZIP_NAME}" # Use absolute path for zip

  echo "----------------------------------------"
  echo "Processing Lambda: $LAMBDA_NAME"
  echo "----------------------------------------"

  # Check if the Lambda subdirectory exists
  if [[ ! -d "$LAMBDA_SUB_DIR" ]]; then
    echo "ERROR: Lambda subdirectory '$LAMBDA_SUB_DIR' not found!"
    exit 1
  fi

  # Check if the main script file exists
  if [[ ! -f "$SCRIPT_PATH" ]]; then
    echo "ERROR: Script '$SCRIPT_PATH' not found!"
    exit 1
  fi

  # --- Install Dependencies (if requirements.txt exists) ---
  if [[ -f "$REQ_FILE" ]]; then
    echo "Found $REQ_FILE. Installing/updating dependencies into '$LAMBDA_SUB_DIR'..."
    # Install dependencies *directly into* the Lambda's subdirectory.
    # The '-t .' targets the current directory (which will be $LAMBDA_SUB_DIR).
    # Using --upgrade ensures we get newer versions if available.
    (cd "$LAMBDA_SUB_DIR" && pip install --upgrade -r requirements.txt -t .)
    echo "Dependency installation complete for $LAMBDA_NAME."
  else
    echo "No requirements.txt found for $LAMBDA_NAME. Skipping pip install."
  fi

  # --- Create Zip Package ---
  echo "Creating zip package: $ZIP_PATH"

  # Change into the Lambda's subdirectory
  cd "$LAMBDA_SUB_DIR"

  # Create the zip file. '-r' includes subdirectories (the libraries).
  # '.' means "zip everything in the current directory".
  # We use the absolute $ZIP_PATH defined earlier.
  zip -r "$ZIP_PATH" .

  # Change back to the original directory before the next loop iteration
  cd "$CURRENT_DIR"

  echo "Successfully created $ZIP_PATH."
  echo "" # Add a blank line for readability

done

echo "========================================"
echo "All Lambda zip packages have been regenerated in $BUILD_DIR/"
echo "========================================"
