
import boto3
import os
import time
import logging
import json
import traceback
import csv
import io
from datetime import datetime
import urllib.parse
import sys # Import sys for stderr

# --- Configuration Constants ---
PROCESSED_SUBDIRS = ["splitcsv", "splitdat", "splitobr"]
SPLITCSV_ERROR_SUBDIR = "splitcsv-error"
INCOMING_DIR_NAME = "incoming"
OUTPUT_FILE_EXTENSION = "hl7"
ERROR_TOPIC_ENV_VAR = 'ERROR_TOPIC_ARN'
CSV_FILE_EXTENSION = '.csv'

# --- HL7 Delimiters (Standard) ---
FIELD_DELIMITER = "|"
COMPONENT_DELIMITER = "^"
SUBCOMPONENT_DELIMITER = "&"
REPETITION_DELIMITER = "~"
ESCAPE_CHARACTER = "\\" # This is the backslash character itself

# --- CSV Headers (MUST match the exact order of your CSV file headers) ---
CSV_HEADERS = [
    "SendingFacility", "Patient_ID", "MRN", "PtLastName", "PtFirstName", "PtMI",
    "DateOfBirth", "Sex", "Race", "Ethnicity", "PatientStreet", "PatientStreet2",
    "PatientCity", "PatientState", "PatientZipcode", "PatientPhoneNumber",
    "AccessionNumber", "OrderedTest_ID", "OrderedTest_name", "SpecimenCollectionDate",
    "SpecimenSite", "OrderingProviderLastName", "OrderingProviderFirstName",
    "OrderingFacilityName", "OrderingFacilityAddress", "OrderingFacilityCity",
    "OrderingFacilityState", "OrderingFacilityZip", "OrderingFacilityPhone",
    "ResultedTestID", "ResultedTestName", "TestResult", "TestDate", "PerformingLab", "Notes"
]
EXPECTED_COLUMNS = len(CSV_HEADERS)

# --- Logging Setup ---
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# --- GLOBAL DEBUG MODE VARIABLE ---
# This can be set via Lambda Environment Variable or directly here.
# It will be passed as an argument to functions that need it.
GLOBAL_DEBUG_MODE = 0 # Default to 0 (off). Set to 1 for debugging.

def report_error(error_msg: str, context) -> None:
    """
    Reports an error by logging it and attempting to publish to an SNS topic.
    """
    logger.error(error_msg)
    try:
        sns = boto3.client('sns')
        topic_arn = os.environ.get(ERROR_TOPIC_ENV_VAR)
        if topic_arn:
            sns.publish(
                TopicArn=topic_arn,
                Subject=f"Lambda Error in {context.function_name if context else 'lambda_split_csv'}",
                Message=error_msg
            )
    except Exception as sns_error:
        logger.warning("SNS publish failed: %s", str(sns_error))

def escape_hl7(text):
    """
    Escapes characters in text that have special meaning in HL7.
    """
    if text is None:
        return ""
    # Per HL7, escape sequences are defined by MSH-2. We are using standard ones.
    # We strip newlines and carriage returns here as part of cleanup.
    return str(text).replace("\r", "").replace("\n", "\\.br\\").replace(FIELD_DELIMITER, "\\F\\").replace(COMPONENT_DELIMITER, "\\S\\").replace(REPETITION_DELIMITER, "\\R\\").replace(ESCAPE_CHARACTER, "\\E\\").replace(SUBCOMPONENT_DELIMITER, "\\T\\")

# --- Date Formatting Function ---
def format_date_for_hl7(date_string, debug_mode: int, include_offset=False):
    """
    Formats date from mm/dd/yyyy [HH:MM:SS] to HMOY[HHMMSS][-HHMM].
    Optionally includes a fixed -0500 offset.
    """
    if not date_string:
        return ""

    date_string = date_string.strip()

    dt_obj = None
    # Try parsing with time first
    try:
        dt_obj = datetime.strptime(date_string, "%m/%d/%Y %H:%M:%S")
    except ValueError:
        # Fall through to date-only parsing
        try:
            dt_obj = datetime.strptime(date_string, "%m/%d/%Y")
        except ValueError:
            if debug_mode == 1:
                print(f"WARNING: Could not parse date '{date_string}'. Returning empty string.", file=sys.stderr)
            return ""

    if dt_obj:
        hl7_date = dt_obj.strftime("%Y%m%d%H%M%S") if " " in date_string else dt_obj.strftime("%Y%m%d")
        if include_offset:
            # For simplicity, using a fixed offset from the working example.
            # In a real system, you'd calculate this based on the actual timezone of the data.
            hl7_date += "-0500" # Example offset from working message
        return hl7_date
    return ""

# --- HL7 Segment Generation Functions ---

def generate_msh(sending_application, sending_facility, message_datetime, message_control_id):
    # Changed receiving_application to VIDOHNBS and receiving_facility to VIDOH as requested
    receiving_application = "VIDOHNBS"
    receiving_facility = "VIDOH"
    message_type = "ORU"
    trigger_event = "R01"
    message_structure = "ORU_R01" # Added the third component for MSH-9
    processing_id = "P"  # P for Production, T for Training, D for Debugging
    version_id = "2.5.1"
    message_profile_id = "PHLabReport-NoAck^^2.16.840.1.113883.9.11^ISO" # MSH-21 from working example

    # MSH-2 Encoding Characters: Corrected to '^~\&' as per user's instruction and working example.
    # This defines the component, repetition, escape, and subcomponent delimiters.
    msh2_encoding_chars = f"{COMPONENT_DELIMITER}{REPETITION_DELIMITER}{ESCAPE_CHARACTER}{SUBCOMPONENT_DELIMITER}"

    # MSH-3 Sending Application (HD data type from working example: LABCORP^2.16.840.1.113883.3.362.90.100^ISO)
    # Using 'sending_application' (derived from folder name) for the name.
    msh3_sending_app = f"{escape_hl7(sending_application)}{COMPONENT_DELIMITER}2.16.840.1.113883.3.362.90.100{COMPONENT_DELIMITER}ISO"

    # MSH-4 Sending Facility (HD data type from working example: LABCORP^34D0655059^CLIA)
    # Using 'sending_facility' from CSV for the name, and a placeholder for CLIA ID.
    msh4_sending_facility = f"{escape_hl7(sending_facility)}{COMPONENT_DELIMITER}34D0655059{COMPONENT_DELIMITER}CLIA"

    # MSH-8 Security (ST) - from working example
    msh8_security = "VI001" 

    # Construct MSH-9 with three components: Message Code^Trigger Event^Message Structure
    msh9 = f"{message_type}{COMPONENT_DELIMITER}{trigger_event}{COMPONENT_DELIMITER}{message_structure}"

    msh_segment = (f"MSH{FIELD_DELIMITER}{msh2_encoding_chars}{FIELD_DELIMITER}" # MSH-2 Corrected
                   f"{msh3_sending_app}{FIELD_DELIMITER}" # MSH-3
                   f"{msh4_sending_facility}{FIELD_DELIMITER}" # MSH-4
                   f"{receiving_application}{FIELD_DELIMITER}" # MSH-5
                   f"{receiving_facility}{FIELD_DELIMITER}" # MSH-6
                   f"{message_datetime}{FIELD_DELIMITER}" # MSH-7
                   f"{msh8_security}{FIELD_DELIMITER}" # MSH-8
                   f"{msh9}{FIELD_DELIMITER}" # MSH-9
                   f"{message_control_id}{FIELD_DELIMITER}" # MSH-10
                   f"{processing_id}{FIELD_DELIMITER}" # MSH-11
                   f"{version_id}") # MSH-12

    # Append remaining fields with empty delimiters up to MSH-20 if needed, then MSH-21
    # Standard MSH has up to 20 fields before the optional MSH-21
    # Count fields already added: 12. Need to add 8 empty fields to reach MSH-20.
    msh_segment += FIELD_DELIMITER * (20 - 12)
    # MSH-13: Sending Facility telecom
    sending_facility_phone = os.environ.get('ORDERING_FACILITY_PHONE', '')
    msh_segment += FIELD_DELIMITER + escape_hl7(sending_facility_phone)  # MSH-13
    # Blank MSH-14 to MSH-20
    msh_segment += FIELD_DELIMITER * (20 - 13)
    # MSH-21: Message Profile ID
    msh_segment += FIELD_DELIMITER + message_profile_id 
    msh_segment += f"{FIELD_DELIMITER}{message_profile_id}" # MSH-21

    return msh_segment

def generate_pid(patient_id, mrn, pt_last_name, pt_first_name, pt_mi, dob, sex, race, ethnicity,
                  patient_street, patient_street2, patient_city, patient_state, patient_zipcode, patient_phone_number):
    pid_segment = f"PID{FIELD_DELIMITER}1"  # Set ID PID-1
    pid_segment += f"{FIELD_DELIMITER}" # PID-2 External ID - empty from CSV
    pid_segment += f"{FIELD_DELIMITER}{escape_hl7(patient_id)}{COMPONENT_DELIMITER}{COMPONENT_DELIMITER}{COMPONENT_DELIMITER}PI{COMPONENT_DELIMITER}PI" # PID-3 Patient ID - Internal ID (Patient_ID as PI)
    pid_segment += f"{FIELD_DELIMITER}{escape_hl7(mrn)}{COMPONENT_DELIMITER}{COMPONENT_DELIMITER}{COMPONENT_DELIMITER}MR{COMPONENT_DELIMITER}MR" # PID-4 Alternate Patient ID (MRN as MR)
    pid_segment += f"{FIELD_DELIMITER}{escape_hl7(pt_last_name)}{COMPONENT_DELIMITER}{escape_hl7(pt_first_name)}{COMPONENT_DELIMITER}{escape_hl7(pt_mi)}"  # PID-5 Patient Name
    pid_segment += f"{FIELD_DELIMITER}" # PID-6 Mothers Maiden Name - empty
    pid_segment += f"{FIELD_DELIMITER}{dob}"  # PID-7 DateOfBirth
    pid_segment += f"{FIELD_DELIMITER}{escape_hl7(sex)}"  # PID-8 Sex
    pid_segment += f"{FIELD_DELIMITER}" # PID-9 Patient Alias - empty
    pid_segment += f"{FIELD_DELIMITER}{escape_hl7(race)}"  # PID-10 Race
    pid_segment += (f"{FIELD_DELIMITER}{escape_hl7(patient_street)}{COMPONENT_DELIMITER}{escape_hl7(patient_street2)}{COMPONENT_DELIMITER}{escape_hl7(patient_city)}{COMPONENT_DELIMITER}"
                    f"{escape_hl7(patient_state)}{COMPONENT_DELIMITER}{escape_hl7(patient_zipcode)}{COMPONENT_DELIMITER}L")  # PID-11 Address
    pid_segment += f"{FIELD_DELIMITER}" # PID-12 County Code - empty
    pid_segment += f"{FIELD_DELIMITER}{escape_hl7(patient_phone_number)}"  # PID-13 Phone Number - Home
    pid_segment += f"{FIELD_DELIMITER}" # PID-14 Phone Number - Business - empty
    pid_segment += f"{FIELD_DELIMITER}" # PID-15 Primary Language - empty
    pid_segment += f"{FIELD_DELIMITER}" # PID-16 Marital Status - empty
    pid_segment += f"{FIELD_DELIMITER}" # PID-17 Religion - empty
    pid_segment += f"{FIELD_DELIMITER}" # PID-18 Patient Account Number - empty
    pid_segment += f"{FIELD_DELIMITER}" # PID-19 SSN - empty
    pid_segment += f"{FIELD_DELIMITER}" # PID-20 Driver's License Number - empty
    pid_segment += f"{FIELD_DELIMITER}" # PID-21 Military Status - empty
    pid_segment += f"{escape_hl7(ethnicity)}" # PID-22 Ethnicity
    return pid_segment

def generate_orc(accession_number, ordering_provider_last, ordering_provider_first,
                  ordering_facility_name, ordering_facility_address, ordering_facility_city,
                  ordering_facility_state, ordering_facility_zip, ordering_facility_phone):
    orc_segment = f"ORC{FIELD_DELIMITER}RE"  # ORC-1
    orc_segment += f"{FIELD_DELIMITER}{escape_hl7(accession_number)}"  # ORC-2 Placer Order #
    orc_segment += f"{FIELD_DELIMITER}{escape_hl7(accession_number)}"  # ORC-3 Filler Order #
    # Blank ORC-4 to ORC-11
    orc_segment += FIELD_DELIMITER * 8
    # ORC-12 Ordering Provider (Last^First)
    orc_segment += f"{FIELD_DELIMITER}{escape_hl7(ordering_provider_last)}{COMPONENT_DELIMITER}{escape_hl7(ordering_provider_first)}"
    # Blank ORC-13 to ORC-16
    orc_segment += FIELD_DELIMITER * 4
    # ORC-17 Ordering Facility details
    orc_segment += (f"{FIELD_DELIMITER}{escape_hl7(ordering_facility_name)}{COMPONENT_DELIMITER}"
                    f"{escape_hl7(ordering_facility_address)}{COMPONENT_DELIMITER}"
                    f"{escape_hl7(ordering_facility_city)}{COMPONENT_DELIMITER}"
                    f"{escape_hl7(ordering_facility_state)}{COMPONENT_DELIMITER}"
                    f"{escape_hl7(ordering_facility_zip)}{COMPONENT_DELIMITER}{COMPONENT_DELIMITER}"
                    f"{escape_hl7(ordering_facility_phone)}")
    return orc_segment

def generate_obr(accession_number, ordered_test_id, ordered_test_name, specimen_collection_date, specimen_site):
    obr_segment = f"OBR{FIELD_DELIMITER}1"  # OBR-1 Set ID
    obr_segment += f"{FIELD_DELIMITER}{escape_hl7(accession_number)}" # OBR-2 Placer Order Number
    obr_segment += f"{FIELD_DELIMITER}{escape_hl7(accession_number)}" # OBR-3 Filler Order Number (using accession as filler)

    # OBR-4 Universal Service Identifier (CWE) - Using OrderedTest_ID and OrderedTest_name from CSV.
    # Placeholder for coding system (LN for LOINC if applicable) and alternate components.
    obr4_cwe = (f"{escape_hl7(ordered_test_id)}{COMPONENT_DELIMITER}{escape_hl7(ordered_test_name)}{COMPONENT_DELIMITER}LN")
    obr_segment += f"{FIELD_DELIMITER}{obr4_cwe}"

    obr_segment += f"{FIELD_DELIMITER}" * 2 # OBR-5 Priority to OBR-6 Requested Date/Time - empty
    #obr_segment += f"{specimen_collection_date}" # OBR-7 Observation Date/Time
    obr_segment += f"{FIELD_DELIMITER}{specimen_collection_date}"
    obr_segment += f"{FIELD_DELIMITER}" * 6 # OBR-8 to OBR-13 - empty
    #obr_segment += f"{specimen_collection_date}" # OBR-14 Specimen Received Date/Time
    obr_segment += f"{FIELD_DELIMITER}{specimen_collection_date}"
    obr_segment += f"{FIELD_DELIMITER}{escape_hl7(specimen_site)}" # OBR-15 Specimen Source

    # obr_segment += FIELD_DELIMITER * (48 - 15) # Fill remaining empty fields up to OBR-48

    # Blank OBR-16 to OBR-24 (9 empty fields)
    obr_segment += FIELD_DELIMITER * 9
    # OBR-25 Result Status = Final
    obr_segment += f"{FIELD_DELIMITER}F"
    # Blank OBR-26 to OBR-48
    obr_segment += FIELD_DELIMITER * (48 - 25)

    return obr_segment

def generate_spm(specimen_id, specimen_site, collection_datetime):
    """
    SPM segment for specimen details:
      SPM-1 Set ID = 1
      SPM-2 Specimen ID = specimen_id
      SPM-4 Specimen Type = specimen_site
      SPM-7 Collection Date/Time = collection_datetime
    """
    spm = f"SPM{FIELD_DELIMITER}1"
    spm += f"{FIELD_DELIMITER}{escape_hl7(specimen_id)}"    # SPM-2 Specimen ID
    spm += f"{FIELD_DELIMITER}"                            # SPM-3 Specimen Parent IDs
    spm += f"{FIELD_DELIMITER}{escape_hl7(specimen_site)}" # SPM-4 Specimen Type
    spm += FIELD_DELIMITER * 2                              # SPM-5,6 blank
    spm += f"{FIELD_DELIMITER}{collection_datetime}"       # SPM-7 Collection Date/Time
    spm += FIELD_DELIMITER * (10 - 7)                      # SPM-8 to SPM-10 blank
    return spm

def generate_obx(result_test_id, resulted_test_name, test_result, test_date, performing_lab, notes):
    obx_segment = f"OBX{FIELD_DELIMITER}1"

    # Determine OBX-2 Value Type and OBX-5 content based on TestResult's nature
    # If the exact system prefers SN even for text, and then a specific code, this needs further refinement.
    try:
        float(test_result) # Attempt to convert to float
        is_numeric_result = True
    except ValueError:
        is_numeric_result = False

    if is_numeric_result:
        obx_value_type = "SN" # Structured Numeric
        # OBX-5 for SN: Empty Comparator ^ Value. Example: ||^2730.0000 --> ^2730.0000
        obx_value = f"{COMPONENT_DELIMITER}{escape_hl7(test_result)}"
    else:
        obx_value_type = "ST" # String Type
        # OBX-5 for ST: Just the string value. NO LEADING COMPONENT_DELIMITER for ST type.
        obx_value = escape_hl7(test_result)
        
    obx_segment += f"{FIELD_DELIMITER}{obx_value_type}" # OBX-2 Value Type

    # OBX-3 Observation Identifier (CWE) - Example: 20447-9^HIV 1 RNA^LN^550413^HIV-1 RNA by PCR^L^2.80^1
    # Using result_test_id and result_test_name from CSV, add placeholders for other components
    # Assuming result_test_id is the primary identifier and result_test_name is its text.
    obx_id_cwe = (f"{escape_hl7(result_test_id)}{COMPONENT_DELIMITER}{escape_hl7(resulted_test_name)}{COMPONENT_DELIMITER}LN{COMPONENT_DELIMITER}"
                  f"550413{COMPONENT_DELIMITER}{escape_hl7(resulted_test_name)}{COMPONENT_DELIMITER}L{COMPONENT_DELIMITER}2.80{COMPONENT_DELIMITER}1")
    obx_segment += f"{FIELD_DELIMITER}{obx_id_cwe}"

    obx_segment += f"{FIELD_DELIMITER}1" # OBX-4 Observation Sub-ID

    obx_segment += f"{FIELD_DELIMITER}{obx_value}" # OBX-5 Observation Value

    # OBX-6 Units (CWE) - Example: copies/mL^copies per milliliter^UCUM^^^^20171130 (4 empty components)
    # Corrected the number of empty components.
    obx_units_cwe = f"copies/mL{COMPONENT_DELIMITER}copies per milliliter{COMPONENT_DELIMITER}UCUM{COMPONENT_DELIMITER}{COMPONENT_DELIMITER}{COMPONENT_DELIMITER}{COMPONENT_DELIMITER}20171130"
    obx_segment += f"{FIELD_DELIMITER}{obx_units_cwe}"

    obx_segment += f"{FIELD_DELIMITER}" * 4 # OBX-7 to OBX-10 (References Range, Abnormals Flags, Probability, Nature of Abnormal Test) - empty

    obx_segment += f"{FIELD_DELIMITER}F" # OBX-11 Observation Result Status (F for Final Results, per working example)

    obx_segment += f"{FIELD_DELIMITER}" * 2 # OBX-12 to OBX-13 (Date Last Obs Normal Values, User Defined Access Checks) - empty

    obx_segment += f"{FIELD_DELIMITER}{test_date}" # OBX-14 Date/Time of Observation (with offset)

    # OBX-15 Producer ID (XON) - Example: 34D0655059^Labcorp Burlington^CLIA
    # Using performing_lab from CSV, adding placeholder for CLIA number and ID.
    obx_producer_id_xon = f"34D0655059{COMPONENT_DELIMITER}{escape_hl7(performing_lab)}{COMPONENT_DELIMITER}CLIA"
    obx_segment += f"{FIELD_DELIMITER}{obx_producer_id_xon}"

    obx_segment += f"{FIELD_DELIMITER}" # OBX-16 Responsible Observer - empty

    # OBX-17 Observation Method (CWE) - Example: 0128^Nucleic acid probe with amplification^OBSMETHOD^^^^20090501
    obx_obs_method_cwe = f"0128{COMPONENT_DELIMITER}Nucleic acid probe with amplification{COMPONENT_DELIMITER}OBSMETHOD{COMPONENT_DELIMITER}{COMPONENT_DELIMITER}{COMPONENT_DELIMITER}{COMPONENT_DELIMITER}{COMPONENT_DELIMITER}20090501"
    obx_segment += f"{FIELD_DELIMITER}{obx_obs_method_cwe}"

    obx_segment += f"{FIELD_DELIMITER}" # OBX-18 Equipment Instance Identifier - empty in working example

    # OBX-19 Date/Time of Analysis - using TestDate. Needs offset.
    obx_segment += f"{FIELD_DELIMITER}{test_date}"

    obx_segment += f"{FIELD_DELIMITER}" # OBX-20 Observation Site - empty
    obx_segment += f"{FIELD_DELIMITER}" # OBX-21 Observation Status - empty (this is different from OBX-11)
    obx_segment += f"{FIELD_DELIMITER}" # OBX-22 Observation Performed by - empty

    # OBX-23 Performing Organization Name (XON) - Example: Labcorp Burlington^D^^^^CLIA&2.16.840.1.113883.4.7&ISO^XX^^^34D0655059
    # Corrected the number of empty components.
    org_name = escape_hl7(performing_lab)
    org_type = "D" # From example
    assigning_auth_id = "CLIA"
    assigning_auth_type = "2.16.840.1.113883.4.7" # OID for CLIA
    assigning_auth_name_type = "ISO"
    org_identifier = "34D0655059" # From example
    
    obx_performing_org_name_xon = (
        f"{org_name}{COMPONENT_DELIMITER}{org_type}{COMPONENT_DELIMITER}{COMPONENT_DELIMITER}{COMPONENT_DELIMITER}{COMPONENT_DELIMITER}"
        f"{assigning_auth_id}{SUBCOMPONENT_DELIMITER}{assigning_auth_type}{SUBCOMPONENT_DELIMITER}{assigning_auth_name_type}{COMPONENT_DELIMITER}"
        f"XX{COMPONENT_DELIMITER}{COMPONENT_DELIMITER}{COMPONENT_DELIMITER}" # Three empty components here
        f"{org_identifier}"
    )
    obx_segment += f"{FIELD_DELIMITER}{obx_performing_org_name_xon}"

    # OBX-24 Performing Organization Address (XAD) - Example: 1447 York Court^^Burlington^NC^27215
    # Using hardcoded from example. If CSV had address for lab, it would go here.
    obx_performing_org_address_xad = f"1447 York Court{COMPONENT_DELIMITER}{COMPONENT_DELIMITER}Burlington{COMPONENT_DELIMITER}NC{COMPONENT_DELIMITER}27215"
    obx_segment += f"{FIELD_DELIMITER}{obx_performing_org_address_xad}"

    # If Notes field is present, add it to OBX-21
    if notes:
        # OBX-21 Observation Result Status (different from OBX-11, this is for free text comments)
        # Note: OBX-21 typically refers to a sub-ID for multiple results, or sometimes
        # a specific status for comments. Placing general 'Notes' here might not be standard.
        # An NTE segment linked to OBR or OBX is more common for free-text notes.
        # However, following previous attempt, putting it at the end of OBX.
        obx_segment += f"{FIELD_DELIMITER}{escape_hl7(notes)}"
    else:
        obx_segment += f"{FIELD_DELIMITER}" # Keep empty if no notes

    return obx_segment

def generate_pv1(patient_class="O", assigned_location="", ordering_provider_last="", ordering_provider_first="", collection_datetime=""):
    """Generate PV1 segment for performer routing"""
    pv1 = f"PV1{FIELD_DELIMITER}1"
    pv1 += f"{FIELD_DELIMITER}{escape_hl7(patient_class)}"  # PV1-2 Patient Class
    pv1 += f"{FIELD_DELIMITER}{escape_hl7(assigned_location)}"  # PV1-3 Assigned Patient Location
    pv1 += FIELD_DELIMITER * 3  # PV1-4..6 blank
    pv1 += f"{FIELD_DELIMITER}{escape_hl7(ordering_provider_last)}{COMPONENT_DELIMITER}{escape_hl7(ordering_provider_first)}"  # PV1-7 Attending Doctor
    pv1 += FIELD_DELIMITER * 36  # PV1-8..43 blank
    pv1 += f"{FIELD_DELIMITER}{collection_datetime}"  # PV1-44 Admit Date/Time
    return pv1

def generate_prd(provider_role="RP", provider_name="", provider_address="", provider_telecom=""):
    """Generate PRD segment for provider details"""
    prd = f"PRD{FIELD_DELIMITER}1"
    prd += f"{FIELD_DELIMITER}{escape_hl7(provider_role)}"  # PRD-2 Provider Role
    prd += f"{FIELD_DELIMITER}{escape_hl7(provider_name)}"  # PRD-3 Provider Name
    prd += f"{FIELD_DELIMITER}{escape_hl7(provider_address)}"  # PRD-4 Provider Address
    prd += f"{FIELD_DELIMITER}{escape_hl7(provider_telecom)}"  # PRD-5 Provider Telecom
    return prd

# --- Sanity Check Function ---
def perform_basic_sanity_checks(field_name: str, field_value: str, debug_mode: int) -> bool:
    """
    Performs basic sanity checks on field values.
    Returns True if check passes, False otherwise.
    """
    if debug_mode == 1:
        logger.info(f"DEBUG_CHECK: Checking '{field_name}' with value: '{field_value}'")

    # Fields explicitly marked 'Required' in the Inductive Health Flat File Message Profile.
    # Plus AccessionNumber as it's critical and explicitly "Required and MUST be unique".
    # And TestDate, ResultedTestID/Name, TestResult, PerformingLab as they are required for OBX/OBR
    # Also including all fields that were 'Required' from the PDF, even if they aren't for the specific OBX/OBR that was working
    # (e.g. Ordering Facility Address).
    
    required_in_pdf_or_critical = [
        "SendingFacility", "Patient_ID", "PtLastName", "PtFirstName",
        "DateOfBirth", "Sex", "AccessionNumber", "OrderedTest_ID", "OrderedTest_name",
        "OrderingProviderLastName", "OrderingProviderFirstName", "OrderingFacilityName",
        "OrderingFacilityAddress", "ResultedTestID", "ResultedTestName",
        "TestResult", "TestDate", "PerformingLab"
    ]

    if field_name in required_in_pdf_or_critical:
        if not field_value:
            logger.error(f"ERROR: Mandatory field '{field_name}' is empty (as per PDF or critical for HL7 generation).")
            return False

    # Specific checks beyond simple emptiness:
    if field_name == "MRN": # PDF states NOT required (can be blank) but must be unique for patient if present.
        if not field_value and debug_mode == 1:
            logger.warning(f"WARNING: MRN is empty. Profile states NOT required, but must be unique if present.")
    elif field_name == "AccessionNumber":
        if debug_mode == 1:
            logger.info(f"DEBUG: Processing AccessionNumber. Raw value: '{field_value}'")
        trimmed_value = field_value.strip()
        if debug_mode == 1:
            logger.info(f"DEBUG: AccessionNumber after trimming whitespace: '{trimmed_value}'")
        if not trimmed_value:
            logger.error("ERROR: Accession Number is empty or contains only whitespace. This is critical.")
            return False

    elif field_name in ["DateOfBirth", "SpecimenCollectionDate", "TestDate"]:
        if not field_value: # Already caught by required_in_pdf_or_critical for some dates
            logger.warning(f"WARNING: Date field '{field_name}' is empty. HL7 date will be empty.")
            # Do not return False here if the PDF says "Not required" for SpecimenCollectionDate.
            # But if it's a 'Required' date, the above check handles it.
        # Check input format (mm/dd/yyyy or mm/dd/yyyy HH:MM:SS)
        if field_value and not (datetime_format_check(field_value, "%m/%d/%Y %H:%M:%S") or datetime_format_check(field_value, "%m/%d/%Y")):
            logger.error(f"ERROR: Input date format for '{field_name}' ('{field_value}') does not match expected mm/dd/yyyy [HH:MM:SS].")
            return False
    elif field_name == "Sex":
        if field_value not in ["M", "F", "U", "O", "A", "N"]:
            logger.warning(f"WARNING: Sex field ('{field_value}') is not a standard HL7 value (M,F,U,O,A,N).")
    elif field_name == "OrderingFacilityAddress": # This is "Required" in PDF
        if not field_value:
            logger.error(f"ERROR: Mandatory field '{field_name}' is empty (as per PDF).")
            return False
    
    return True

def datetime_format_check(date_string, format_string):
    """Helper to check if a string matches a datetime format."""
    try:
        datetime.strptime(date_string.strip(), format_string)
        return True
    except ValueError:
        return False

def generate_hl7_message_from_csv_row(row: dict, message_id_for_msh: str, sending_application: str, debug_mode: int) -> str:
    """
    Generates an HL7 ORU^R01 message from a single CSV row.
    Validates required fields and formats.
    """
    # Safely get all values, strip them, default to empty string if missing
    # This also ensures all CSV_HEADERS exist as keys in 'mapped_data' for safety.
    mapped_data = {header: row.get(header, '').strip() for header in CSV_HEADERS}

    # Assign values to local variables for use in generation functions
    # Using specific names for clarity.
    sending_facility = mapped_data["SendingFacility"]
    patient_id = mapped_data["Patient_ID"]
    mrn = mapped_data["MRN"]
    pt_last_name = mapped_data["PtLastName"]
    pt_first_name = mapped_data["PtFirstName"]
    pt_mi = mapped_data["PtMI"]
    date_of_birth_raw = mapped_data["DateOfBirth"]
    sex = mapped_data["Sex"]
    race = mapped_data["Race"]
    ethnicity = mapped_data["Ethnicity"]
    patient_street = mapped_data["PatientStreet"]
    patient_street2 = mapped_data["PatientStreet2"]
    patient_city = mapped_data["PatientCity"]
    patient_state = mapped_data["PatientState"]
    patient_zipcode = mapped_data["PatientZipcode"]
    patient_phone_number = mapped_data["PatientPhoneNumber"]
    accession_number = mapped_data["AccessionNumber"]
    ordered_test_id = mapped_data["OrderedTest_ID"]
    ordered_test_name = mapped_data["OrderedTest_name"]
    specimen_collection_date_raw = mapped_data["SpecimenCollectionDate"]
    specimen_site = mapped_data["SpecimenSite"]
    ordering_provider_last_name = mapped_data["OrderingProviderLastName"]
    ordering_provider_first_name = mapped_data["OrderingProviderFirstName"]
    ordering_facility_name = mapped_data["OrderingFacilityName"]
    ordering_facility_address = mapped_data["OrderingFacilityAddress"]
    ordering_facility_city = mapped_data["OrderingFacilityCity"]
    ordering_facility_state = mapped_data["OrderingFacilityState"]
    ordering_facility_zip = mapped_data["OrderingFacilityZip"]
    ordering_facility_phone = mapped_data["OrderingFacilityPhone"]
    resulted_test_id = mapped_data["ResultedTestID"]
    resulted_test_name = mapped_data["ResultedTestName"]
    test_result = mapped_data["TestResult"]
    test_date_raw = mapped_data["TestDate"]
    performing_lab = mapped_data["PerformingLab"]
    notes = mapped_data["Notes"]

    # --- Perform Basic Sanity Checks ---
    # This loop ensures ALL checks are performed and logs errors/warnings.
    # If any check returns False, 'all_checks_pass' will become False.
    all_checks_pass = True
    for header in CSV_HEADERS:
        # Pass the correct value from mapped_data to the sanity check function
        if not perform_basic_sanity_checks(header, mapped_data[header], debug_mode):
            all_checks_pass = False # A critical error occurred

    if not all_checks_pass:
        raise ValueError("One or more mandatory fields failed validation for this row.")
    
    # --- Format Dates for HL7 ---
    # MSH-7 Date/Time of Message (using TestDate)
    msh_timestamp = format_date_for_hl7(test_date_raw, debug_mode, include_offset=True) # MSH-7 now includes offset as per working example.

    # PID-7 DateOfBirth
    formatted_date_of_birth = format_date_for_hl7(date_of_birth_raw, debug_mode)

    # OBR-7 & OBR-14 Specimen Collection Date (from CSV field, with offset as per working example)
    formatted_specimen_collection_date = format_date_for_hl7(specimen_collection_date_raw, debug_mode, include_offset=True)

    # OBX-14 & OBX-19 Test Date (from CSV field, with offset as per working example)
    formatted_test_date = format_date_for_hl7(test_date_raw, debug_mode, include_offset=True)

    if debug_mode == 1:
        logger.info(f"DEBUG: Formatted MSH Timestamp: '{msh_timestamp}'")
        logger.info(f"DEBUG: Formatted DateOfBirth: '{formatted_date_of_birth}'")
        logger.info(f"DEBUG: Formatted SpecimenCollectionDate: '{formatted_specimen_collection_date}'")
        logger.info(f"DEBUG: Formatted TestDate (with offset): '{formatted_test_date}'")

    # --- Generate HL7 Message Segments ---
    hl7_message_parts = [
    generate_msh(sending_application, sending_facility, msh_timestamp, message_id_for_msh),
    # Insert SFT segment
    f"SFT{FIELD_DELIMITER}1{FIELD_DELIMITER}{os.getenv('SOFTWARE_VENDOR','')}{FIELD_DELIMITER}{os.getenv('SOFTWARE_PRODUCT','')}{FIELD_DELIMITER}{os.getenv('SOFTWARE_VERSION','')}{FIELD_DELIMITER}{os.getenv('SOFTWARE_RELEASE','')}",
    generate_pid(patient_id, mrn, pt_last_name, pt_first_name, pt_mi, formatted_date_of_birth,
                 sex, race, ethnicity, patient_street, patient_street2, patient_city,
                 patient_state, patient_zipcode, patient_phone_number),
    generate_pv1(patient_class="O", assigned_location="", ordering_provider_last=ordering_provider_last_name, ordering_provider_first=ordering_provider_first_name, collection_datetime=formatted_specimen_collection_date),
    generate_orc(accession_number, ordering_provider_last_name, ordering_provider_first_name,
                 ordering_facility_name, ordering_facility_address, ordering_facility_city,
                 ordering_facility_state, ordering_facility_zip, ordering_facility_phone),
    generate_obr(accession_number, ordered_test_id, ordered_test_name, formatted_specimen_collection_date, specimen_site),
    generate_spm(accession_number, specimen_site, formatted_specimen_collection_date),
    generate_obx(resulted_test_id, resulted_test_name, test_result, formatted_test_date, performing_lab, notes),
    # Add NTE segment for free-text notes linked to OBX
    f"NTE{FIELD_DELIMITER}1{FIELD_DELIMITER}L{FIELD_DELIMITER}{escape_hl7(notes)}",
    generate_prd(provider_role="RP", provider_name=f"{ordering_provider_last_name}^{ordering_provider_first_name}", provider_address=ordering_facility_address, provider_telecom=ordering_facility_phone),
]

    
    return "\r".join(hl7_message_parts) # Changed segment terminator to \r

def get_s3_object_content(s3_client: boto3.client, bucket_name: str, key: str, context) -> str:
    s3_object_content = None
    for attempt_num in range(3):
        try:
            obj = s3_client.get_object(Bucket=bucket_name, Key=key)
            s3_object_content = obj['Body'].read().decode('utf-8-sig') # Use utf-8-sig for potential BOM
            break
        except s3_client.exceptions.NoSuchKey:
            logger.warning(f"Attempt {attempt_num+1}: Key not found: {key}. Retrying in 1 second.")
            time.sleep(1)
        except Exception as e:
            error_message = f"Error getting S3 object {key} on attempt {attempt_num+1}: {e}\n{traceback.format_exc()}"
            report_error(error_message, context)
            raise
    if s3_object_content is None:
        error_message = f"Failed to retrieve S3 object after 3 attempts: {key}"
        report_error(error_message, context)
        raise RuntimeError(error_message)
    return s3_object_content

def process_csv_content_and_upload_hl7(
    s3_client: boto3.client,
    s3_bucket_name: str,
    success_key_template: str,
    error_file_output_dir: str,
    error_file_base_name: str,
    csv_content: str,
    sending_application: str,
    context
) -> int:
    csv_file = io.StringIO(csv_content)
    try:
        csv_reader = csv.DictReader(csv_file)
    except Exception as e: # Catch all csv.reader related errors during init
        err_msg = f"Failed to initialize CSV reader: {e}"
        logger.error(err_msg)
        report_error(err_msg, context)
        try:
            error_file_key = f"{error_file_output_dir}{error_file_base_name}_CSV_READER_INIT_error.csv"
            logger.info(f"Saving original CSV content due to reader init failure to {error_file_key}")
            s3_client.put_object(Bucket=s3_bucket_name, Key=error_file_key, Body=csv_content.encode('utf-8'))
        except Exception as e_save_error:
            logger.error(f"Failed to save CSV to error location after reader init failure: {e_save_error}")
        return 0

    if not csv_reader.fieldnames:
        err_msg = "CSV file has no field names (headers). Cannot process."
        logger.error(err_msg)
        report_error(err_msg, context)
        try:
            error_file_key = f"{error_file_output_dir}{error_file_base_name}_NO_HEADERS_error.csv"
            logger.info(f"Saving original CSV content due to no headers to {error_file_key}")
            s3_client.put_object(Bucket=s3_bucket_name, Key=error_file_key, Body=csv_content.encode('utf-8'))
        except Exception as e_save_error:
            logger.error(f"Failed to save no_headers CSV to error location: {e_save_error}")
        return 0
        
    # Standardize header names by stripping whitespace
    cleaned_fieldnames = [name.strip() for name in csv_reader.fieldnames]
    csv_reader.fieldnames = cleaned_fieldnames

    if len(cleaned_fieldnames) != EXPECTED_COLUMNS:
        err_msg = f"CSV header mismatch. Expected {EXPECTED_COLUMNS} columns, but found {len(cleaned_fieldnames)}. This may lead to processing errors or incorrect data mapping."
        logger.warning(err_msg)
        report_error(err_msg, context)

    # Check if the *names* of the headers match the expected ones
    for expected_header in CSV_HEADERS:
        if expected_header not in cleaned_fieldnames:
            err_msg = f"CSV header mismatch: Expected column '{expected_header}' not found in CSV headers: {cleaned_fieldnames}. This will cause mapping errors."
            logger.error(err_msg)
            report_error(err_msg, context)
            return 0 # Stop processing this file as mapping will be broken

    logger.info(f"CSV Headers (cleaned): {csv_reader.fieldnames}")

    processed_message_count = 0
    for i, row_original in enumerate(csv_reader):
        row_number = i + 1
        row = {
            str(key).strip(): str(value).strip() if value is not None else ''
            for key, value in row_original.items() if key is not None
        }

        for header in CSV_HEADERS:
            if header not in row:
                row[header] = ''

        msh_patient_id = row.get('Patient_ID', f'UnknownPID{row_number}')
        msh_test_id = row.get('ResultedTestID', f'UnknownTest{row_number}')
        message_id_for_msh = f"{msh_patient_id}_{msh_test_id}_{row_number}_{datetime.now().strftime('%f')}"
        
        try:
            # Pass sending_application and GLOBAL_DEBUG_MODE
            hl7_message = generate_hl7_message_from_csv_row(row, message_id_for_msh, sending_application, GLOBAL_DEBUG_MODE)
            
            output_s3_key = success_key_template.format(row_number)
            logger.info(f"Writing HL7 message for CSV row {row_number} (MSH ID: {message_id_for_msh}) to {output_s3_key}")
            s3_client.put_object(
                Bucket=s3_bucket_name, Key=output_s3_key, Body=hl7_message.encode('utf-8')
            )
            processed_message_count += 1
            
        except ValueError as ve:
            error_log_message = f"Data validation error for CSV row {row_number}: {ve}"
            logger.error(f"{error_log_message}. Original row data (first 200 chars): {str(row_original)[:200]}")
            report_error(f"{error_log_message}. See logs for row data.", context)

            error_file_content = f"Error: {ve}\nProblematic CSV Row Number: {row_number}\nOriginal Row Data:\n{json.dumps(row_original)}"
            error_file_name = f"{error_file_base_name}_{row_number}_validation_error.txt"
            error_file_key = f"{error_file_output_dir}{error_file_name}"
            try:
                logger.info(f"Saving problematic row {row_number} details to {error_file_key}")
                s3_client.put_object(Bucket=s3_bucket_name, Key=error_file_key, Body=error_file_content.encode('utf-8'))
            except Exception as e_save:
                logger.error(f"Failed to save validation error file for row {row_number} to {error_file_key}: {e_save}")
            continue
            
        except Exception as e:
            error_log_message = f"General failure processing CSV row {row_number}: {e}"
            logger.error(f"{error_log_message}\n{traceback.format_exc()}. Original row data (first 200 chars): {str(row_original)[:200]}")
            report_error(f"{error_log_message}. See logs for row data and traceback.", context)

            error_file_content = f"General Error: {e}\nTraceback: {traceback.format_exc()}\nProblematic CSV Row Number: {row_number}\nOriginal Row Data:\n{json.dumps(row_original)}"
            error_file_name = f"{error_file_base_name}_{row_number}_general_processing_error.txt"
            error_file_key = f"{error_file_output_dir}{error_file_name}"
            try:
                logger.info(f"Saving general failure details for row {row_number} to {error_file_key}")
                s3_client.put_object(Bucket=s3_bucket_name, Key=error_file_key, Body=error_file_content.encode('utf-8'))
            except Exception as e_save:
                logger.error(f"Failed to save general error file for row {row_number} to {error_file_key}: {e_save}")
            continue
            
    return processed_message_count

def lambda_handler(event, context):
    # Retrieve DEBUG_MODE from environment variable or use default
    # This makes it configurable in Lambda console.
    global GLOBAL_DEBUG_MODE
    GLOBAL_DEBUG_MODE = int(os.environ.get('DEBUG_MODE', '0'))

    logger.info("Received event: %s", json.dumps(event))
    s3_client = boto3.client('s3')

    for record in event['Records']:
        s3_bucket_name = record['s3']['bucket']['name']
        s3_object_key_encoded = record['s3']['object']['key']
        s3_object_key = urllib.parse.unquote_plus(s3_object_key_encoded)
        logger.info(f"Decoded S3 object key: {s3_object_key}")

        is_processed_or_error_path = False
        for subdir_name in PROCESSED_SUBDIRS + [SPLITCSV_ERROR_SUBDIR]:
            if f"/{subdir_name}/" in s3_object_key:
                is_processed_or_error_path = True
                break
        
        if is_processed_or_error_path:
            logger.info(f"Skipping file already in a processed or error directory for splitcsv: {s3_object_key}")
            continue
        
        s3_key_components = s3_object_key.split('/')
        if len(s3_key_components) < 4: # Expected: site/user/incoming/file.csv
            logger.warning(f"Unexpected S3 key format (too few components): {s3_object_key}. Skipping.")
            report_error(f"Unexpected S3 key format (too few components): {s3_object_key}. Expected at least site/user/incoming/file.csv", context)
            continue
        if s3_key_components[-2] != INCOMING_DIR_NAME:
            logger.warning(f"S3 key not in '{INCOMING_DIR_NAME}' directory: {s3_object_key}. Skipping.")
            report_error(f"S3 key not in '{INCOMING_DIR_NAME}' directory: {s3_object_key}. Expected file to be in 'incoming' folder.", context)
            continue
        if not s3_object_key.lower().endswith(CSV_FILE_EXTENSION):
            logger.info(f"Skipping non-{CSV_FILE_EXTENSION} file: {s3_object_key}")
            continue

        try:
            site_path_components = s3_key_components[:-3] 
            extracted_username = s3_key_components[-3] # This is the folder name preceding 'incoming'
            base_output_path = '/'.join(site_path_components + [extracted_username])
            
            original_file_name = os.path.basename(s3_object_key)
            original_file_name_without_ext = original_file_name.rsplit('.', 1)[0]
            
            base_filename_for_outputs = f"{extracted_username}_{original_file_name_without_ext}"

            success_output_dir = f"{base_output_path}/{PROCESSED_SUBDIRS[0]}/"
            success_key_template = f"{success_output_dir}{base_filename_for_outputs}_{{}}.{OUTPUT_FILE_EXTENSION}"
            
            error_output_dir = f"{base_output_path}/{SPLITCSV_ERROR_SUBDIR}/"
            
            # Derived sending_application from folder name preceding incoming
            derived_sending_application = extracted_username.upper() # Convert to uppercase as common for app names

            logger.info(f"Derived Sending Application: {derived_sending_application}")
            logger.info(f"Success output key template: {success_key_template}")
            logger.info(f"Error output directory: {error_output_dir} with base name: {base_filename_for_outputs}")

        except IndexError:
            report_error(f"Could not determine output paths or sending application for {s3_object_key} due to unexpected key structure.", context)
            continue

        try:
            s3_object_content = get_s3_object_content(s3_client, s3_bucket_name, s3_object_key, context)
        except RuntimeError:
            continue

        message_count = process_csv_content_and_upload_hl7(
            s3_client,
            s3_bucket_name,
            success_key_template,
            error_output_dir,
            base_filename_for_outputs,
            s3_object_content,
            derived_sending_application, # Pass the derived sending_application
            context
        )
        
        summary = f"Processed {message_count} HL7 messages from CSV file {s3_object_key}"
        logger.info(summary)
        # Optional: Send success summary to SNS (e.g., if message_count > 0)

    return {"status": "csv processing complete"}
