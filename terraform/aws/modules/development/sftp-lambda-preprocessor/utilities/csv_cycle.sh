#!/usr/bin/env bash
set -euo pipefail

###########################
# Configuration variables #
###########################
SLEEP_TIME=60                   # for any fixed sleeps you still want
WAIT_SLEEP=15                   # how long to wait between polls
TIMEOUT=360                     # total seconds before giving up
TMP_DIR=~/hl7tmp
TMP_FILE_PREFIX=test7

SFTP_BUCKET=s3://sftp.example.com
SFTP_SITE=examplesite-test
S3_INCOMING="s3://{SFTP_BUCKET}/${SFTP_SITE}/test-testauto/incoming/"
S3_SPLITCSV="s3://{SFTP_BUCKET}/${SFTP_SITE}/test-testauto/splitcsv/"
S3_DLIP="s3://{SFTP_BUCKET}/${SFTP_SITE}/incoming/"
S3_PROCESSED="s3://{SFTP_BUCKET}/${SFTP_SITE}/incoming/processed/"

######################
# Helper: wait for a #
# new file on S3     #
######################
wait_for_new_file() {
  local s3path=$1
  local start_ts=$2

  echo "Waiting up to ${TIMEOUT}s for a new file in ${s3path} after $(date -d "@${start_ts}")"
  local now elapsed raw_list latest_line file_date_str file_ts

  while true; do
    #echo "DEBUG: aws s3 ls ${s3path}"
    raw_list=$(aws s3 ls "${s3path}")
    echo "${raw_list}"

    #echo "DEBUG: aws s3 ls sorted"
    sorted_list=$(echo "${raw_list}" | sort)
    echo "${sorted_list}"

    latest_line=$(echo "${sorted_list}" | tail -n1)
    #echo "DEBUG: sorted latest_line = '${latest_line}'"

    if [[ -n "${latest_line// /}" ]]; then
      # parse "YYYY-MM-DD  HH:MM:SS  size  filename"
      file_date_str=$(echo "$latest_line" | awk '{print $1 " " $2}')
      #echo "DEBUG: parsed file_date_str = '${file_date_str}'"
      file_ts=$(date -d "$file_date_str" +%s)
      #echo "DEBUG: parsed file_ts = ${file_ts}, start_ts = ${start_ts}"

      if (( file_ts > start_ts )); then
        echo "→ Detected new file: $latest_line"
        return 0
      fi
    else
      echo "DEBUG: No files returned by aws s3 ls."
    fi

    now=$(date +%s)
    elapsed=$(( now - start_ts ))
    if (( elapsed >= TIMEOUT )); then
      echo "✗ Timeout (${TIMEOUT}s) waiting for new file in ${s3path}" >&2
      return 1
    fi

    echo "No new file yet in ${s3path} (elapsed ${elapsed}s). Sleeping ${WAIT_SLEEP}s..."
    sleep "${WAIT_SLEEP}"
  done
}

##################
# Main execution #
##################
START_TIME=$(date +%s)
echo "#################################################################################################"
echo "Starting time: $(date)"

cd "${TMP_DIR}"

echo
echo "1) Uploading CSV to incoming..."
aws s3 cp "${TMP_FILE_PREFIX}.csv" "${S3_INCOMING}"

echo
echo "2) Waiting for splitcsv to appear…"
if ! wait_for_new_file "${S3_SPLITCSV}" "${START_TIME}"; then
  echo "Exiting due to timeout on splitcsv." >&2
  exit 1
fi

echo
echo "3) Syncing splitcsv down locally…"
aws s3 sync "${S3_SPLITCSV}" .

echo
echo "4) Uploading HL7 to DI processes…"
aws s3 cp "usvi-test-testauto_${TMP_FILE_PREFIX}_1.hl7" "${S3_DLIP}"

echo
echo "5) Waiting for incoming/processed to appear…"
if ! wait_for_new_file "${S3_PROCESSED}" "${START_TIME}"; then
  echo "Exiting due to timeout on incoming/processed." >&2
  exit 1
fi

echo
echo "6) Syncing processed logs…"
aws s3 sync "${S3_PROCESSED}" .

echo
echo "7) Showing most recent .log:"
ls -1 *.log | tail -1 | xargs cat

echo
echo "Ending time: $(date)"
