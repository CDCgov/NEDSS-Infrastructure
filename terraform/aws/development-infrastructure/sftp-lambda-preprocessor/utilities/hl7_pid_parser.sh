
#!/bin/bash

# Script to process an HL7 file and extract PID segment details with alignment.

# --- Configuration ---
HL7_FILE=$1
PID_COUNT=0

# --- Field Name Mappings (Add more as needed) ---
declare -A PID_FIELD_NAMES
PID_FIELD_NAMES[1]="Set ID - PID"
PID_FIELD_NAMES[2]="Patient ID"
PID_FIELD_NAMES[3]="Patient Identifier List"
PID_FIELD_NAMES[4]="Alternate Patient ID - PID"
PID_FIELD_NAMES[5]="Patient Name"
PID_FIELD_NAMES[6]="Mother's Maiden Name"
PID_FIELD_NAMES[7]="Date/Time of Birth"
PID_FIELD_NAMES[8]="Administrative Sex"
PID_FIELD_NAMES[9]="Patient Alias"
PID_FIELD_NAMES[10]="Race"
PID_FIELD_NAMES[11]="Patient Address"
PID_FIELD_NAMES[12]="County Code"
PID_FIELD_NAMES[13]="Phone Number - Home"
PID_FIELD_NAMES[14]="Phone Number - Business"
PID_FIELD_NAMES[15]="Primary Language"
PID_FIELD_NAMES[16]="Marital Status"
PID_FIELD_NAMES[17]="Religion"
PID_FIELD_NAMES[18]="Patient Account Number"
PID_FIELD_NAMES[19]="SSN Number - Patient"
PID_FIELD_NAMES[20]="Driver's License Number"
PID_FIELD_NAMES[21]="Mother's Identifier"
PID_FIELD_NAMES[22]="Ethnic Group"
PID_FIELD_NAMES[23]="Birth Place"
PID_FIELD_NAMES[24]="Multiple Birth Indicator"
PID_FIELD_NAMES[25]="Birth Order"
PID_FIELD_NAMES[26]="Citizenship"
PID_FIELD_NAMES[27]="Veterans Military Status"
PID_FIELD_NAMES[28]="Nationality"
PID_FIELD_NAMES[29]="Patient Death Date and Time"
PID_FIELD_NAMES[30]="Patient Death Indicator"
PID_FIELD_NAMES[31]="Identity Unknown Indicator"
PID_FIELD_NAMES[32]="Identity Reliability Code"
PID_FIELD_NAMES[33]="Last Update Date/Time"
PID_FIELD_NAMES[34]="Last Update Facility"

# --- Calculate Max Field Name Length for Formatting ---
MAX_NAME_LEN=0
DEFAULT_NAME="Unspecified Field"
for name in "${PID_FIELD_NAMES[@]}"; do
    len=${#name}
    if (( len > MAX_NAME_LEN )); then
        MAX_NAME_LEN=$len
    fi
done
# Ensure it's at least as long as the default
if (( ${#DEFAULT_NAME} > MAX_NAME_LEN )); then
    MAX_NAME_LEN=${#DEFAULT_NAME}
fi
# Add 3 for '()' and space
MAX_NAME_LEN=$((MAX_NAME_LEN + 3))

# --- Functions ---

# Function to display usage instructions
usage() {
  echo "Usage: $0 <path_to_hl7_file>"
  exit 1
}

# Function to process a single PID line
process_pid_line() {
  local line=$1
  local fields
  local i
  local field_value
  local field_name
  local hl7_index
  local pid_label
  local name_label

  # Increment PID counter
  ((PID_COUNT++))

  echo "--- PID Segment ${PID_COUNT} ---"

  # Set IFS to | for splitting, read the line into an array
  IFS='|' read -r -a fields <<< "$line"

  # Print the Segment Name (fields[0])
  echo "Segment Name: ${fields[0]}"

  # Iterate through the fields *starting from index 1*
  for i in $(seq 1 $((${#fields[@]} - 1))); do
    # HL7 index is the same as the loop index 'i' now
    hl7_index=$i

    # Get the field value
    field_value=${fields[$i]}

    # Get the field name from our map, or use a default
    field_name=${PID_FIELD_NAMES[$hl7_index]:-$DEFAULT_NAME}

    # Check for empty fields
    if [[ -z "$field_value" ]]; then
      field_value="<empty>"
    fi

    # Prepare labels for printf
    pid_label="PID-${hl7_index}"
    name_label="(${field_name})"

    # Use printf for aligned output
    # %-10s : Left-align PID-X in 10 chars
    # %-Ns   : Left-align (Name) in N chars (N = MAX_NAME_LEN)
    # %s     : Print the value
    printf "  %-10s %-*s : %s\n" "$pid_label" "$MAX_NAME_LEN" "$name_label" "$field_value"
  done

  echo "----------------------"
  echo "" # Add a blank line for better separation
}


# --- Main Script ---

# Check if an argument was provided
if [[ -z "$HL7_FILE" ]]; then
  echo "Error: No HL7 file path provided."
  usage
fi

# Check if the file exists
if [[ ! -f "$HL7_FILE" ]]; then
  echo "Error: File not found at '$HL7_FILE'."
  usage
fi

echo "Processing HL7 file: $HL7_FILE"
echo ""

# Read the file line by line and look for PID segments
while IFS= read -r line || [[ -n "$line" ]]; do
  # Remove potential carriage returns for cross-platform compatibility
  line=$(echo "$line" | tr -d '\r')

  # Check if the line starts with "PID|"
  if [[ $line == PID\|* ]]; then
    process_pid_line "$line"
  fi
done < "$HL7_FILE"

# Check if any PID segments were found
if [[ $PID_COUNT -eq 0 ]]; then
  echo "No PID segments found in the file."
fi

echo "Processing complete."
