#!/bin/bash

# A script to transfer files from a source to a destination SFTP server.
#
# Features:
# - Checks for downloaded files to prevent duplicates.
# - Uses a staging directory for transfers.
# - Command-line flags for dry-run, debug, and configuration.
# - Interactive setup for the configuration file.
# - Supports subdirectory mapping based on filename prefixes.
# - Default additive-only upload mode; deletions can be enabled via flag.

set -euo pipefail

CONFIG_FILE="./.sftp_transfer.rc"
STAGING_DIR="./sftp_staging"
LOG_FILE="./downloaded.log"

# Default flag values
DRY_RUN=0
DEBUG=0
CONFIGURE=0
ENABLE_DELETES=0 # Default is 0, meaning NO deletes.
KEEP_STAGING=1

usage() {
  echo "Usage: $0 [-n] [-d] [-c] [-k] [-s] [-h]"
  echo "  -n  Dry run: show what would be done without actually transferring files."
  echo "  -d  Debug mode: enable verbose command execution output (set -x)."
  echo "  -c  Configure: prompt to create or update SFTP credentials and paths."
  echo "  -k  Keep staging: prevents cleaning the staging directory before the run."
  echo "  -s  Sync mode: allows deleting files on the destination. Default is additive."
  echo "  -h  Display this help message."
  exit 1
}

# --- Process command-line options ---
while getopts "ndcksh" opt; do
  case ${opt} in
    n) DRY_RUN=1 ;;
    d) DEBUG=1 ;;
    c) CONFIGURE=1 ;;
    k) KEEP_STAGING=1 ;;
    s) ENABLE_DELETES=1 ;;
    h) usage ;;
    *) usage ;;
  esac
done
shift $((OPTIND -1))

# Enable debug mode if requested
if [[ "$DEBUG" -eq 1 ]]; then
  set -x
fi

# --- Dependency Check ---
if ! command -v lftp &> /dev/null; then
  echo "Error: 'lftp' is not installed or not in your PATH. Please install it to continue." >&2
  exit 1
fi

# --- Configuration Function ---
configure_rc() {
  echo "--- Configuring SFTP Details ---"
  
  # Load existing values if file exists
  if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
  fi

  # Helper function to read input with a default value
  read_input() {
    local prompt="$1"
    local var_name="$2"
    local current_val="${!var_name:-}" # Indirect expansion to get current value
    local new_val
    read -p "$prompt [$current_val]: " new_val
    export "$var_name"="${new_val:-$current_val}"
  }

  read_input "Enter Source SFTP User" SRC_SFTP_USER
  read_input "Enter Source SFTP Password" SRC_SFTP_PASS
  read_input "Enter Source SFTP Host" SRC_SFTP_HOST
  read_input "Enter Source SFTP Path" SRC_SFTP_PATH
  echo ""
  read_input "Enter Destination SFTP User" DST_SFTP_USER
  read_input "Enter Destination SFTP Password" DST_SFTP_PASS
  read_input "Enter Destination SFTP Host" DST_SFTP_HOST
  read_input "Enter Destination SFTP Path" DST_SFTP_PATH

  # Write configuration to file
  cat > "$CONFIG_FILE" <<EOF
# SFTP Configuration - Generated on $(date)
export SRC_SFTP_USER="${SRC_SFTP_USER}"
export SRC_SFTP_PASS="${SRC_SFTP_PASS}"
export SRC_SFTP_HOST="${SRC_SFTP_HOST}"
export SRC_SFTP_PATH="${SRC_SFTP_PATH}"

export DST_SFTP_USER="${DST_SFTP_USER}"
export DST_SFTP_PASS="${DST_SFTP_PASS}"
export DST_SFTP_HOST="${DST_SFTP_HOST}"
export DST_SFTP_PATH="${DST_SFTP_PATH}"

# Optional: Define subdirectory mappings using 'PREFIX:SUBDIRECTORY' format.
# The script will check if a filename starts with the PREFIX and place it
# in the corresponding SUBDIRECTORY in staging and on the destination.
# Example:
# export SUBDIR_MAPPINGS=(
#   "Partner~Cancer:Cancer"
#   "partner~elim:elim"
#   "ACME_CORP:ACME"
# )
EOF
  echo "Configuration saved to $CONFIG_FILE"
  echo "You can now edit $CONFIG_FILE to add subdirectory mappings."
}

# --- Load or Create Config ---
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Configuration file not found: $CONFIG_FILE"
  read -p "Would you like to create it now? (y/n): " create_confirm
  if [[ "$create_confirm" == "y" ]]; then
    configure_rc
  else
    echo "Cannot proceed without a configuration file. Exiting."
    exit 1
  fi
elif [[ "$CONFIGURE" -eq 1 ]]; then
  echo "Re-configuring SFTP details..."
  configure_rc
fi

# Load the final config
source "$CONFIG_FILE"
# Ensure SUBDIR_MAPPINGS is defined as an array to prevent errors if it's not in the RC file
declare -a SUBDIR_MAPPINGS=${SUBDIR_MAPPINGS:-()}


# --- Main Script ---
echo "Starting SFTP transfer process..."
if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "--- DRY RUN MODE ENABLED ---"
fi

# Ensure staging directory exists and optionally clean it
if [[ "$KEEP_STAGING" -eq 0 ]]; then
  if [[ "$DRY_RUN" -eq 0 ]]; then
    echo "Cleaning staging directory: $STAGING_DIR"
    rm -rf "${STAGING_DIR:?}"/* # Protect against unbound variable
    mkdir -p "$STAGING_DIR"
  else
    echo "DRY RUN: Would clean staging directory: $STAGING_DIR"
  fi
else
    echo "Preserving staging directory as requested."
    mkdir -p "$STAGING_DIR" # Still ensure it exists
fi
touch "$LOG_FILE"


########################################################
# List files from source SFTP, ignoring any subdirectories
echo "Connecting to source SFTP to list files..."

# STEP 1: Get the raw, detailed directory listing from the SFTP server
# and store it in a temporary variable.
RAW_FILE_LIST=$(
    lftp -u "$SRC_SFTP_USER","$SRC_SFTP_PASS" sftp://"$SRC_SFTP_HOST" <<EOF
    cls -l "$SRC_SFTP_PATH"
    bye
EOF
)

# STEP 2: Use a simple, clean pipeline to filter the data from the
# temporary variable and save the final, clean list of filenames.
FILE_LIST=$(
    echo "$RAW_FILE_LIST" | grep '^[-]' | awk '{$1=$2=$3=$4=$5=$6=$7=$8=""; print $0}' | sed 's/^[ ]*//'
)

# You can test if this worked by adding a debug line right here:
echo "--- DEBUG START ---"
echo "$FILE_LIST"
echo "--- DEBUG END ---"
# exit 1

########################################################

########################################################
# Iterate over files and download if not already downloaded
########################################################
echo "Processing and downloading new files..."
# The 'while read' loop is recommended for handling filenames with spaces.
# If you have a 'for' loop, this fix will still work.
#while IFS= read -r FILE; do
#  if [[ -z "$FILE" ]]; then continue; fi # Skip empty lines

for FILE in $FILE_LIST; do
  # Get just the filename from the full path provided by the server
  local_filename=$(basename "$FILE")

  # Check the log using only the filename for more robust duplicate detection
  if grep -Fxq "$local_filename" "$LOG_FILE"; then
    echo "Skipping already downloaded file: $local_filename"
    continue
  fi

  # --- START of new "unsorted" directory logic ---

  target_subdir=""
  # Check against mappings using the clean filename
  for mapping in "${SUBDIR_MAPPINGS[@]}"; do
    IFS=':' read -r prefix subdir <<< "$mapping"
    if [[ "$local_filename" == "$prefix"* ]]; then
      target_subdir="$subdir"
      break
    fi
  done

  # If no mapping was found after checking all prefixes, assign it to "unsorted"
  if [[ -z "$target_subdir" ]]; then
    target_subdir="unsorted"
  fi

  # Now, build the path and message using the guaranteed target_subdir
  local_path="$STAGING_DIR/$target_subdir/$local_filename"
  download_message="Downloading: $local_filename -> $STAGING_DIR/$target_subdir/"

  # Create the target directory if it doesn't exist
  if [[ "$DRY_RUN" -eq 0 ]]; then
    mkdir -p "$STAGING_DIR/$target_subdir"
  fi

  # --- END of new "unsorted" directory logic ---

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "DRY RUN: $download_message"
    continue
  fi

  echo "$download_message"
  lftp -u "$SRC_SFTP_USER","$SRC_SFTP_PASS" sftp://"$SRC_SFTP_HOST" <<EOF
set xfer:log true
# Use the original $FILE variable, as it contains the correct full remote path
get "$FILE" -o "$local_path"
bye
EOF

  # Log only the filename to the downloaded log
  echo "$local_filename" >> "$LOG_FILE"
done

########################################################
# Push the entire staging directory structure to the destination SFTP
echo "Uploading staged files to destination SFTP..."
mirror_opts="--reverse --verbose --parallel=5"


if [[ "$ENABLE_DELETES" -eq 0 ]]; then
  # For additive mode, we add no delete-related flags. This is compatible
  # with both old and new versions of lftp.
  echo "INFO: Additive mode is default. Files will not be deleted on destination. (Use -s to enable deletions)"
else
  # For sync mode, we must explicitly add the --delete flag.
  mirror_opts+=" --delete"
  echo "INFO: Sync mode (-s) enabled. Files on destination may be deleted to match staging."
fi



if [[ "$DRY_RUN" -eq 1 ]]; then
    mirror_opts+=" --dry-run"
    echo "DRY RUN: Would mirror local '$STAGING_DIR' to remote '$DST_SFTP_PATH'"
fi

lftp -u "$DST_SFTP_USER","$DST_SFTP_PASS" sftp://"$DST_SFTP_HOST" <<EOF
set xfer:log true
mirror $mirror_opts "$STAGING_DIR" "$DST_SFTP_PATH"
bye
EOF

echo "SFTP transfer process completed."
