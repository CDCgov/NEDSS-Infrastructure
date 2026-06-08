
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
import sys

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
GLOBAL_DEBUG_MODE = int(os.environ.get('DEBUG_MODE', '0')) # Default to 0 (off).

# --- Helper Dictionaries and Functions ---

def report_error(error_msg: str, context) -> None:
    """Reports an error by logging it and attempting to publish to an SNS topic."""
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
    """Escapes characters in text that have special meaning in HL7."""
    if text is None:
        return ""
    return str(text).replace("\r", "").replace("\n", "\\.br\\").replace(FIELD_DELIMITER, "\\F\\").replace(COMPONENT_DELIMITER, "\\S\\").replace(REPETITION_DELIMITER, "\\R\\").replace(ESCAPE_CHARACTER, "\\E\\").replace(SUBCOMPONENT_DELIMITER, "\\T\\")

def datetime_format_check(date_string, debug_mode: int, include_offset=False):
    """
    Checks if a date string is in the 'mm/dd/yyyy' or 'mm/dd/yyyy HH:M:SS' format.
    Returns the formatted date string 'YYYYMMDD' or 'YYYYMMDDHHMMSS' if valid, otherwise returns an empty string.
    If include_offset is True, appends '-0500' to the formatted date.
    """
    if not date_string:
        return ""
    
    date_string = date_string.strip()
    
    try:
        # First, try to parse with time
        dt_obj = datetime.strptime(date_string, "%m/%d/%Y %H:%M:%S")
        hl7_date = dt_obj.strftime("%Y%m%d%H%M%S")
    except ValueError:
        try:
            # If that fails, try to parse date only
            dt_obj = datetime.strptime(date_string, "%m/%d/%Y")
            hl7_date = dt_obj.strftime("%Y%m%d")
        except ValueError:
            # If both fail, it's an invalid format
            # Optionally, log this event if in debug mode
            if debug_mode == 1:
                print(f"WARNING: The date '{date_string}' is not in 'mm/dd/yyyy' or 'mm/dd/yyyy HH:MM:SS' format. An empty string will be returned.", file=sys.stderr)
            return ""

    if include_offset:
        hl7_date += "-0500"
        
    return hl7_date

def get_ethnicity_cwe(code: str) -> str:
    """Returns a formatted CWE string for a given ethnicity code."""
    ethnicity_map = {"H": "H^Hispanic or Latino^HL70189", "N": "N^Not Hispanic or Latino^HL70189", "U": "U^Unknown^HL70189"}
    return ethnicity_map.get(code.upper(), f"^{escape_hl7(code)}^L")

def get_test_result_cwe(result: str) -> tuple:
    """Returns a formatted CWE string and an abnormal flag for a given text result."""
    result_map = {
        "NEGATIVE": ("260385009^Negative^SCT", "N^Normal^HL70078"),
        "POSITIVE": ("10828004^Positive^SCT", "A^Abnormal^HL70078"),
    }
    return result_map.get(result.upper(), (f"^{escape_hl7(result)}^L", "N^Normal^HL70078"))

def generate_provider_xcn(last_name, first_name):
    """Creates a formatted XCN string for a provider with a placeholder NPI."""
    npi = "9999999999" 
    return f"{escape_hl7(npi)}{COMPONENT_DELIMITER}{escape_hl7(last_name)}{COMPONENT_DELIMITER}{escape_hl7(first_name)}{COMPONENT_DELIMITER}{COMPONENT_DELIMITER}{COMPONENT_DELIMITER}{COMPONENT_DELIMITER}NPI{SUBCOMPONENT_DELIMITER}2.16.840.1.113883.4.6{SUBCOMPONENT_DELIMITER}ISO{COMPONENT_DELIMITER}{COMPONENT_DELIMITER}{COMPONENT_DELIMITER}{COMPONENT_DELIMITER}NPI"

def generate_nte_for_notes(notes: str):
    """Generates an NTE segment if notes are present."""
    if notes and notes.strip():
        return f"NTE{FIELD_DELIMITER}1{FIELD_DELIMITER}L{FIELD_DELIMITER}{escape_hl7(notes)}"
    return None

def get_specimen_type_cwe(site_text: str) -> str:
    """(MODIFIED) Returns a coded specimen type for SPM-4."""
    # If the input text is empty or None, return a default "Unknown" code.
    if not site_text:
        return "122555007^Specimen from unknown site^SCT"
        
    specimen_map = {
        "BLOOD": "119297000^Blood specimen^SCT",
        "SERUM": "119364003^Serum specimen^SCT",
        "URINE": "122575003^Urine specimen^SCT",
        "SWAB": "445295009^Swab specimen^SCT",
        "NASAL SWAB": "258500001^Nasal swab^SCT",
        "OROPHARYNGEAL SWAB": "258529004^Oropharyngeal swab^SCT"
    }
    # Convert input to uppercase for case-insensitive matching
    return specimen_map.get(site_text.upper(), f"^{escape_hl7(site_text)}^L")


def perform_basic_sanity_checks(csv_reader: csv.DictReader, context) -> bool:
    """
    Performs basic sanity checks on the CSV headers.
    
    Args:
        csv_reader: A csv.DictReader object.
        context: The Lambda context object for logging.
        
    Returns:
        True if all checks pass, False otherwise.
    """
    if not csv_reader.fieldnames:
        report_error("CSV file has no headers.", context)
        return False
    
    missing_headers = [h for h in CSV_HEADERS if h not in csv_reader.fieldnames]
    if missing_headers:
        report_error(f"CSV is missing required headers: {', '.join(missing_headers)}", context)
        return False

    return True

# --- HL7 Segment Generation Functions ---

def generate_msh(row, message_id_for_msh, debug_mode):
    """
    Generates the MSH (Message Header) segment.
    """
    sending_application = row.get('SendingApplication', 'UnknownApp')
    sending_facility = row.get('SendingFacility', 'UnknownFacility')
    
    message_datetime = datetime_format_check(row.get('TestDate', ''), debug_mode, include_offset=True)
    
    receiving_application = "VIDOH"
    receiving_facility = "VI"
    message_type = "ORU^R01^ORU_R01"
    processing_id = "P"
    version_id = "2.5.1"
    
    msh_segment = (f"MSH{FIELD_DELIMITER}^~\\&{FIELD_DELIMITER}{escape_hl7(sending_application)}^{COMPONENT_DELIMITER}2.16.840.1.113883.3.362.90.100{COMPONENT_DELIMITER}ISO{FIELD_DELIMITER}"
                   f"{escape_hl7(sending_facility)}^{COMPONENT_DELIMITER}34D0655059{COMPONENT_DELIMITER}CLIA{FIELD_DELIMITER}"
                   f"{receiving_application}{FIELD_DELIMITER}{receiving_facility}{FIELD_DELIMITER}"
                   f"{message_datetime}{FIELD_DELIMITER}VI001{FIELD_DELIMITER}{message_type}{FIELD_DELIMITER}"
                   f"{message_id_for_msh}{FIELD_DELIMITER}{processing_id}{FIELD_DELIMITER}{version_id}{FIELD_DELIMITER}"
                   f"||AL|USA||||PHLabReport-NoAck^^2.16.840.1.113883.9.11^ISO|PHLabReport-NoAck^^2.16.840.1.113883.9.11^ISO")
    
    return msh_segment

def generate_pid(row, debug_mode):
    """
    Generates the PID (Patient Identification) segment.
    """
    dob = datetime_format_check(row.get('DateOfBirth', ''), debug_mode)
    
    zipcode = str(row.get('PatientZipcode', '')).zfill(5)
    
    pid_segment = (f"PID{FIELD_DELIMITER}1{FIELD_DELIMITER}|{escape_hl7(row.get('Patient_ID',''))}^^^PI^PI|"
                   f"{escape_hl7(row.get('MRN',''))}^^^MR^MR|{escape_hl7(row.get('PtLastName',''))}^{escape_hl7(row.get('PtFirstName',''))}^{escape_hl7(row.get('PtMI',''))}||"
                   f"{dob}|{escape_hl7(row.get('Sex',''))}||{escape_hl7(row.get('Race',''))}|{escape_hl7(row.get('PatientStreet',''))}^{escape_hl7(row.get('PatientStreet2',''))}^{escape_hl7(row.get('PatientCity',''))}^{escape_hl7(row.get('PatientState',''))}^{zipcode}||"
                   f"{escape_hl7(row.get('PatientPhoneNumber',''))}|||||||||{get_ethnicity_cwe(row.get('Ethnicity',''))}")

    return pid_segment

def generate_pv1(row, provider_xcn, debug_mode):
    """
    Generates the PV1 (Patient Visit) segment.
    """
    collection_date = datetime_format_check(row.get('SpecimenCollectionDate', ''), debug_mode, include_offset=True)
    
    pv1_segment = (f"PV1|1|O|||||{provider_xcn}|||||||||||||||||||||||||||||||||||{collection_date}")
    
    return pv1_segment

def generate_orc(row, provider_xcn):
    """
    Generates the ORC (Common Order) segment.
    """
    facility_name = escape_hl7(row.get('OrderingFacilityName',''))
    facility_address = f"{escape_hl7(row.get('OrderingFacilityAddress',''))}^^{escape_hl7(row.get('OrderingFacilityCity',''))}^{escape_hl7(row.get('OrderingFacilityState',''))}^{str(row.get('OrderingFacilityZip','')).zfill(5)}"
    facility_phone = f"^WPN^PH^^^^{escape_hl7(row.get('OrderingFacilityPhone','')).replace('-', '')}"

    orc_segment = (f"ORC|RE|{escape_hl7(row.get('AccessionNumber',''))}|{escape_hl7(row.get('AccessionNumber',''))}||||||||"
                   f"|{provider_xcn}|||||||||{facility_name}|{facility_address}|{facility_phone}")

    return orc_segment
    
def generate_obr(row, debug_mode):
    """
    Generates the OBR (Observation Request) segment.
    """
    collection_date = datetime_format_check(row.get('SpecimenCollectionDate', ''), debug_mode)
    
    obr_segment = (f"OBR|1|{escape_hl7(row.get('AccessionNumber',''))}|{escape_hl7(row.get('AccessionNumber',''))}|{escape_hl7(row.get('OrderedTest_ID',''))}"
                   f"^{escape_hl7(row.get('OrderedTest_name',''))}^LN|||{collection_date}|||||||{collection_date}|{escape_hl7(row.get('SpecimenSite',''))}"
                   f"||||||||||F")
    
    return obr_segment

def generate_obx(row, debug_mode):
    """
    Generates the OBX (Observation/Result) segment.
    """
    test_date = datetime_format_check(row.get('TestDate', ''), debug_mode)
    
    obx_value_type = "CWE"
    result_cwe, abnormal_flag = get_test_result_cwe(row.get('TestResult',''))
    result_value = result_cwe

    obx_segment = (f"OBX|1|{obx_value_type}|{escape_hl7(row.get('ResultedTestID',''))}^{escape_hl7(row.get('ResultedTestName',''))}^LN^|1|{result_value}|||{abnormal_flag}"
                   f"|||F|||{test_date}|{escape_hl7(row.get('PerformingLab',''))}^^^^^CLIA&2.16.840.1.113883.4.7&ISO^XX^^^34D0655059||"
                   f"0128^Nucleic acid probe with amplification^OBSMETHOD||{test_date}")

    return obx_segment

def generate_spm(row, debug_mode):
    """
    Generates the SPM (Specimen) segment.
    """
    collection_date = datetime_format_check(row.get('SpecimenCollectionDate', ''), debug_mode)
    specimen_type_cwe = get_specimen_type_cwe(row.get('SpecimenSite',''))
    
    spm_segment = f"SPM|1|{escape_hl7(row.get('AccessionNumber',''))}||{specimen_type_cwe}|||{collection_date}"
    
    return spm_segment

def generate_hl7_message_from_csv_row(row: dict, message_id_for_msh: str, sending_application: str, debug_mode: int) -> str:
    """
    Generates a complete HL7 ORU^R01 message from a single CSV row.
    """
    
    provider_xcn = generate_provider_xcn(row.get('OrderingProviderLastName',''), row.get('OrderingProviderFirstName',''))

    hl7_message_parts = [
        generate_msh(row, message_id_for_msh, debug_mode),
        generate_pid(row, debug_mode),
        generate_pv1(row, provider_xcn, debug_mode),
        generate_orc(row, provider_xcn),
        generate_obr(row, debug_mode),
        generate_obx(row, debug_mode),
        generate_spm(row, debug_mode),
        generate_nte_for_notes(row.get('Notes', ''))
    ]
    
    return "\r".join(filter(None, hl7_message_parts))


def get_s3_object_content(s3_client: boto3.client, bucket_name: str, key: str, context) -> str:
    """
    Retrieves the content of an S3 object with retries.
    """
    for attempt in range(3):
        try:
            obj = s3_client.get_object(Bucket=bucket_name, Key=key)
            return obj['Body'].read().decode('utf-8-sig')
        except s3_client.exceptions.NoSuchKey:
            logger.warning(f"Attempt {attempt+1}: Key not found: {key}. Retrying...")
            time.sleep(1)
        except Exception as e:
            report_error(f"Error getting S3 object {key} on attempt {attempt+1}: {e}", context)
            raise
    
    raise RuntimeError(f"Failed to retrieve S3 object after 3 attempts: {key}")


def process_csv_content_and_upload_hl7(
    s3_client: boto3.client, s3_bucket_name: str, success_key_template: str, error_file_output_dir: str,
    error_file_base_name: str, csv_content: str, sending_application: str, context
) -> int:
    """
    Processes the content of a CSV file, generates HL7 messages for each row, 
    and uploads them to S3.
    """
    csv_file = io.StringIO(csv_content)
    
    try:
        csv_reader = csv.DictReader(csv_file)
        cleaned_fieldnames = [name.strip() for name in csv_reader.fieldnames]
        csv_reader.fieldnames = cleaned_fieldnames
    except Exception as e:
        report_error(f"Failed to initialize CSV reader for {error_file_base_name}: {e}", context)
        return 0

    if not perform_basic_sanity_checks(csv_reader, context):
        return 0

    processed_count = 0
    for i, row in enumerate(csv_reader):
        row_number = i + 1
        try:
            message_id = f"{row.get('Patient_ID', 'NA')}_{row.get('AccessionNumber', 'NA')}_{row_number}_{int(time.time())}"
            
            hl7_message = generate_hl7_message_from_csv_row(row, message_id, sending_application, GLOBAL_DEBUG_MODE)
            
            output_key = success_key_template.format(row_number)
            
            s3_client.put_object(Bucket=s3_bucket_name, Key=output_key, Body=hl7_message.encode('utf-8'))
            processed_count += 1
            logger.info(f"Successfully generated and uploaded HL7 for row {row_number} to {output_key}")

        except Exception as e:
            error_message = f"Failed to process CSV row {row_number}: {e}\n{traceback.format_exc()}"
            report_error(error_message, context)
            
            error_key = f"{error_file_output_dir}{error_file_base_name}_{row_number}_error.txt"
            error_content = f"Error: {error_message}\nRow Data: {json.dumps(row)}"
            s3_client.put_object(Bucket=s3_bucket_name, Key=error_key, Body=error_content.encode('utf-8'))
            
    return processed_count

def lambda_handler(event, context):
    """
    Main Lambda function handler triggered by S3 events.
    """
    logger.info("Received event: %s", json.dumps(event, indent=2))
    
    s3_client = boto3.client('s3')

    for record in event['Records']:
        s3_bucket_name = record['s3']['bucket']['name']
        s3_object_key = urllib.parse.unquote_plus(record['s3']['object']['key'])
        
        key_parts = s3_object_key.split('/')
        
        is_processed_or_error_path = any(f"/{subdir}/" in s3_object_key for subdir in PROCESSED_SUBDIRS + [SPLITCSV_ERROR_SUBDIR])
        
        is_invalid_path = len(key_parts) < 3 or key_parts[-2] != INCOMING_DIR_NAME
        
        is_not_csv = not s3_object_key.lower().endswith(CSV_FILE_EXTENSION)
        
        if is_processed_or_error_path or is_invalid_path or is_not_csv:
            logger.info(f"Skipping file due to path or extension constraints: {s3_object_key}")
            continue

        try:
            sending_application = key_parts[-3].upper()
            base_output_path = '/'.join(key_parts[:-2])
            
            original_file_name_no_ext = os.path.basename(s3_object_key).rsplit('.', 1)[0]
            
            base_filename = f"{sending_application}_{original_file_name_no_ext}"
            success_output_dir = f"{base_output_path}/{PROCESSED_SUBDIRS[0]}/"
            success_key_template = f"{success_output_dir}{base_filename}_{{}}.{OUTPUT_FILE_EXTENSION}"
            error_output_dir = f"{base_output_path}/{SPLITCSV_ERROR_SUBDIR}/"

            csv_content = get_s3_object_content(s3_client, s3_bucket_name, s3_object_key, context)
            
            message_count = process_csv_content_and_upload_hl7(
                s3_client, s3_bucket_name, success_key_template, error_output_dir,
                base_filename, csv_content, sending_application, context
            )
            
            logger.info(f"Processed {message_count} messages from {s3_object_key}")

        except Exception as e:
            report_error(f"Unhandled error for {s3_object_key}: {e}\n{traceback.format_exc()}", context)
            continue
            
    return {"status": "Processing complete"}
