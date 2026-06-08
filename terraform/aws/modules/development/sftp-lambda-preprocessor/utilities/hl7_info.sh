#!/bin/bash

# Usage: ./parse_hl7.sh path_to_hl7_file.hl7

HL7_FILE="$1"

if [[ ! -f "$HL7_FILE" ]]; then
  echo "❌ HL7 file not found: $HL7_FILE"
  exit 1
fi

# Normalize line endings to Unix-style
clean_lines=$(tr '\r' '\n' < "$HL7_FILE")

# Extract segments
MSH=$(echo "$clean_lines" | grep '^MSH')
PID=$(echo "$clean_lines" | grep '^PID')
OBR=$(echo "$clean_lines" | grep '^OBR' | head -n 1)

# Use '|' as field delimiter
FIELD_SEPARATOR='|'

# Helper to extract a field (1-based)
extract_field() {
  local line="$1"
  local field_number="$2"
  echo "$line" | awk -F"$FIELD_SEPARATOR" -v num="$field_number" '{print $num}'
}

# MSH fields
msg_type=$(extract_field "$MSH" 9)
sending_app=$(extract_field "$MSH" 3)

# PID fields
patient_id=$(extract_field "$PID" 4)
patient_name=$(extract_field "$PID" 6)
dob=$(extract_field "$PID" 8)
sex=$(extract_field "$PID" 9)
race=$(extract_field "$PID" 11)
ethnicity=$(extract_field "$PID" 23)
last_update=$(extract_field "$PID" 34)

# OBR fields
accession_number=$(extract_field "$OBR" 4)

# Display extracted info
echo "HL7 Message Information:"
echo "-----------------------------"
echo "Message Type     : $msg_type"
echo "Sending App      : $sending_app"
echo "Patient Name     : $patient_name"
echo "Patient ID       : $patient_id"
echo "Date of Birth    : $dob"
echo "Sex              : $sex"
echo "Race             : $race"
echo "Ethnicity        : $ethnicity"
echo "Last Updated     : $last_update"
echo "Accession Number : $accession_number"
echo "-----------------------------"

