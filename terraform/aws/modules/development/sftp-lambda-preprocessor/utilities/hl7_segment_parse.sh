#!/usr/bin/env bash
set -euo pipefail

# Usage: ./parse_hl7.sh <hl7_message_file>
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <hl7_message_file>"
  exit 1
fi

hl7file="$1"
if [[ ! -r "$hl7file" ]]; then
  echo "Error: Cannot read '$hl7file'"
  exit 1
fi

# Convert CR to LF, then for each nonempty segment:
tr '\r' '\n' < "$hl7file" | while IFS='|' read -ra fields; do
  [[ ${#fields[@]} -eq 0 || -z "${fields[0]}" ]] && continue

  segment="${fields[0]}"
  # Print the segment name
  printf "%s\n" "$segment"

  # Print each field: “    SEG-NN: value”
  for (( i=1; i<${#fields[@]}; i++ )); do
    num=$(printf "%02d" "$i")
    printf "    %s-%s: %s\n" "$segment" "$num" "${fields[i]}"
  done
done

