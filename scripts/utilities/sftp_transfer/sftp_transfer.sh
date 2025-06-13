#!/bin/bash

# requires lftp
# could use sshpass as well

set -euo pipefail

CONFIG_FILE="./.sftp_transfer.rc"
STAGING_DIR="./sftp_staging"
LOG_FILE="./downloaded.log"

# Load config
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Missing config file: $CONFIG_FILE"
  exit 1
fi
source "$CONFIG_FILE"

# Ensure staging and log directory
mkdir -p "$STAGING_DIR"
touch "$LOG_FILE"

echo "Starting SFTP transfer process..."

# List files from source SFTP
echo "Connecting to source SFTP to list files..."
FILE_LIST=$(lftp -u "$SRC_SFTP_USER","$SRC_SFTP_PASS" sftp://"$SRC_SFTP_HOST" <<EOF
cls -1 "$SRC_SFTP_PATH"
bye
EOF
)

# Iterate over files and download if not already downloaded
for FILE in $FILE_LIST; do
  if grep -Fxq "$FILE" "$LOG_FILE"; then
    echo "Already downloaded: $FILE"
    continue
  fi

  echo "Downloading: $FILE"
  lftp -u "$SRC_SFTP_USER","$SRC_SFTP_PASS" sftp://"$SRC_SFTP_HOST" <<EOF
cd "$SRC_SFTP_PATH"
get "$FILE" -o "$STAGING_DIR/$FILE"
bye
EOF

  echo "$FILE" >> "$LOG_FILE"
done

# Push files to destination SFTP
echo "Uploading to destination SFTP..."
for FILE in "$STAGING_DIR"/*; do
  BASENAME=$(basename "$FILE")
  echo "Uploading: $BASENAME"
  lftp -u "$DST_SFTP_USER","$DST_SFTP_PASS" sftp://"$DST_SFTP_HOST" <<EOF
cd "$DST_SFTP_PATH"
put "$FILE"
bye
EOF
done

echo "SFTP transfer process completed."

