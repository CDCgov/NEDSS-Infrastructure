#!/usr/bin/env bash
set -euo pipefail

# Usage check
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <csv_file>"
  exit 1
fi

csvfile="$1"

# File check
if [[ ! -r "$csvfile" ]]; then
  echo "Error: Cannot read file '$csvfile'"
  exit 1
fi

# Read header line into an array
IFS=, read -r -a headers < <(head -n1 "$csvfile")

echo "########################################################"
# Process each subsequent line
tail -n +2 "$csvfile" | while IFS=, read -r -a values; do
  # For each field, print "    Header: Value"
  for idx in "${!headers[@]}"; do
    header="${headers[idx]}"
    value="${values[idx]:-}"  # handle missing trailing fields
    echo "    ${header}: ${value}"
  done
  # Row delimiter
  echo "########################################################"
done

