
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

# --- Configuration Constants ---
PROCESSED_SUBDIRS = ["splitcsv", "splitdat", "splitobr"]
# Define the error subdirectory separately
SPLITCSV_ERROR_SUBDIR = "splitcsv-error" # New directory for error files
INCOMING_DIR_NAME = "incoming"
OUTPUT_FILE_EXTENSION = "hl7"
ERROR_TOPIC_ENV_VAR = 'ERROR_TOPIC_ARN'
CSV_FILE_EXTENSION = '.csv'

# --- Logging Setup ---
logger = logging.getLogger()
logger.setLevel(logging.INFO)

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
    return str(text).replace("\n", "\\.br\\").replace("\r", "").replace("|", "\\F\\")

def generate_hl7_message_from_csv_row(row: dict, message_id_for_msh: str) -> str:
    """
    Generates an HL7 ORU^R01 message from a single CSV row.
    Validates required fields and formats.
    """
    try:
        # Ensure all required date fields are present and not empty before stripping
        required_date_fields = {'TestDate', 'DateOfBirth'}
        missing_or_empty_date_fields = [
            field for field in required_date_fields if not row.get(field, '').strip()
        ]
        if missing_or_empty_date_fields:
            raise ValueError(f"Missing or empty required date field(s) in CSV row: {', '.join(missing_or_empty_date_fields)}")

        msh_timestamp = datetime.strptime(row['TestDate'].strip(), "%m/%d/%Y").strftime("%Y%m%d%H%M")
        dob = datetime.strptime(row['DateOfBirth'].strip(), "%m/%d/%Y").strftime("%Y%m%d")
    except ValueError as e: # Catches issues from strptime (empty string after strip, wrong format) or custom check
        raise ValueError(f"Invalid or missing date format (e.g., TestDate='{row.get('TestDate')}', DateOfBirth='{row.get('DateOfBirth')}'): {e}")

    accession_original_value = row.get('AccessionNumber', '')
    accession_raw = accession_original_value.strip()
    
    invalid_accession_patterns = ['null', 'none', 'na', 'n/a', '#n/a', ''] # Added empty string check here explicitly
    if not accession_raw or accession_raw.lower() in invalid_accession_patterns:
        logger.debug(f"Invalid AccessionNumber found: '{accession_original_value}' for MSH ID {message_id_for_msh}.") # Debug, error raised next
        raise ValueError(f"AccessionNumber is missing, empty, or invalid (e.g., 'null', 'NA'). Value: '{accession_original_value}'")
    
    accession = escape_hl7(accession_raw)

    try:
        # Define required fields and check for their presence and non-emptiness after stripping
        required_fields_map = {
            'ResultedTestID': 'ResultedTestID',
            'ResultedTestName': 'ResultedTestName',
            'Patient_ID': 'Patient_ID',
            'PtLastName': 'PtLastName',
            'PtFirstName': 'PtFirstName',
            'Sex': 'Sex',
            'SendingFacility': 'SendingFacility',
            'TestResult': 'TestResult'
        }
        
        # Store stripped values to avoid multiple strip calls and ensure they are used
        cv = {} # Cleaned values
        for key, csv_header in required_fields_map.items():
            val = row.get(csv_header, '').strip()
            if not val:
                raise ValueError(f"Required field '{csv_header}' is missing or empty.")
            cv[key] = val

        resulted_test_id = cv['ResultedTestID']
        resulted_test_name = escape_hl7(cv['ResultedTestName'])
        patient_id = cv['Patient_ID']
        pt_last_name = escape_hl7(cv['PtLastName'])
        pt_first_name = escape_hl7(cv['PtFirstName'])
        sex = cv['Sex']
        sending_facility = escape_hl7(cv['SendingFacility'])
        test_result = escape_hl7(cv['TestResult'])

    except ValueError as e: # Catches custom check for missing/empty fields
        raise ValueError(f"Required CSV column missing/empty for MSH ID {message_id_for_msh}: {e}")
    except KeyError as e: # Fallback, should be caught by custom check
        raise ValueError(f"Missing expected CSV column key for MSH ID {message_id_for_msh}: {e}")

    obr4 = f"{resulted_test_id}^{resulted_test_name}"

    return "\n".join([
        f"MSH|^~\\&|SFTP_APP|{sending_facility}|ELR_RECEIVER|VI_DOH|{msh_timestamp}||ORU^R01|{message_id_for_msh}|P|2.5.1",
        f"PID|||{patient_id}||{pt_last_name}^{pt_first_name}||{dob}|{sex}",
        "ORC|RE||||||||",
        f"OBR|1|{patient_id}|{accession}|{obr4}|||{msh_timestamp}",
        f"OBX|1|TX|{obr4}||{test_result}||||||F"
    ])

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
    success_key_template: str,    # Renamed for clarity
    error_file_output_dir: str, # New: Base S3 directory for error files
    error_file_base_name: str,  # New: Base name for error files (e.g., user_originalcsv)
    csv_content: str,
    context
) -> int:
    csv_file = io.StringIO(csv_content)
    try:
        dialect = csv.Sniffer().sniff(csv_file.read(2048))
        csv_file.seek(0)
        csv_reader = csv.DictReader(csv_file, dialect=dialect)
    except csv.Error:
        logger.warning("CSV Sniffer could not determine dialect. Assuming comma delimiter.")
        csv_file.seek(0)
        csv_reader = csv.DictReader(csv_file)

    if not csv_reader.fieldnames:
        err_msg = "CSV file has no field names (headers). Cannot process."
        logger.error(err_msg)
        report_error(err_msg, context)
        # Save the problematic CSV content itself to the error directory
        try:
            error_file_key = f"{error_file_output_dir}{error_file_base_name}_NO_HEADERS_error.csv"
            logger.info(f"Saving original CSV content due to no headers to {error_file_key}")
            s3_client.put_object(Bucket=s3_bucket_name, Key=error_file_key, Body=csv_content.encode('utf-8'))
        except Exception as e_save_error:
            logger.error(f"Failed to save no_headers CSV to error location: {e_save_error}")
        return 0
        
    csv_reader.fieldnames = [name.strip() for name in csv_reader.fieldnames]
    logger.info(f"CSV Headers: {csv_reader.fieldnames}")

    processed_message_count = 0
    for i, row_original in enumerate(csv_reader):
        row_number = i + 1
        # Clean keys and string values in the row (strip whitespace)
        # Ensure all values are treated as strings before stripping, handle None
        row = {
            str(key).strip() if key is not None else f"unknown_header_{idx}": 
            str(value).strip() if value is not None else '' 
            for idx, (key, value) in enumerate(row_original.items())
        }

        # MSH-10 Message Control ID
        msh_patient_id = row.get('Patient_ID', f'UnknownPID{row_number}')
        msh_test_id = row.get('ResultedTestID', f'UnknownTest{row_number}')
        message_id_for_msh = f"{msh_patient_id}_{msh_test_id}_{row_number}"
        
        try:
            hl7_message = generate_hl7_message_from_csv_row(row, message_id_for_msh)
            
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
            continue # Skip to the next row
            
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
            continue # Skip to the next row
            
    return processed_message_count

def lambda_handler(event, context):
    logger.info("Received event: %s", json.dumps(event))
    s3_client = boto3.client('s3')

    for record in event['Records']:
        s3_bucket_name = record['s3']['bucket']['name']
        s3_object_key_encoded = record['s3']['object']['key']
        s3_object_key = urllib.parse.unquote_plus(s3_object_key_encoded)
        logger.info(f"Decoded S3 object key: {s3_object_key}")

        if any(f"/{PROCESSED_SUBDIRS[0]}/" in s3_object_key or f"/{SPLITCSV_ERROR_SUBDIR}/" in s3_object_key for subdir_to_check in PROCESSED_SUBDIRS + [SPLITCSV_ERROR_SUBDIR]):
             # Check if in any of the main processed subdirs or the specific error dir for this lambda
            if f"/{PROCESSED_SUBDIRS[0]}/" in s3_object_key or f"/{SPLITCSV_ERROR_SUBDIR}/" in s3_object_key:
                logger.info(f"Skipping file already in a processed or error directory for splitcsv: {s3_object_key}")
                continue
        
        s3_key_components = s3_object_key.split('/')
        if len(s3_key_components) < 4: # site/user/incoming/file.csv
            logger.warning(f"Unexpected S3 key format (too few components): {s3_object_key}. Skipping.")
            continue
        if s3_key_components[-2] != INCOMING_DIR_NAME:
            logger.warning(f"S3 key not in '{INCOMING_DIR_NAME}' directory: {s3_object_key}. Skipping.")
            continue
        if not s3_object_key.lower().endswith(CSV_FILE_EXTENSION):
            logger.info(f"Skipping non-{CSV_FILE_EXTENSION} file: {s3_object_key}")
            continue

        try:
            # Path components for S3 output structure
            # e.g. s3_object_key = "rawfiles/cdcv Джулиан Ассанж/incoming/my~file.csv"
            # site_path_components = ["rawfiles"]
            # extracted_username = "cdcv Джулиан Ассанж"
            # base_output_path = "rawfiles/cdcv Джулиан Ассанж"
            site_path_components = s3_key_components[:-3] 
            extracted_username = s3_key_components[-3] 
            base_output_path = '/'.join(site_path_components + [extracted_username])
            
            original_file_name = os.path.basename(s3_object_key)
            original_file_name_without_ext = original_file_name.rsplit('.', 1)[0]
            
            base_filename_for_outputs = f"{extracted_username}_{original_file_name_without_ext}"

            success_output_dir = f"{base_output_path}/{PROCESSED_SUBDIRS[0]}/" # ".../splitcsv/"
            success_key_template = f"{success_output_dir}{base_filename_for_outputs}_{{}}.{OUTPUT_FILE_EXTENSION}"
            
            error_output_dir = f"{base_output_path}/{SPLITCSV_ERROR_SUBDIR}/" # ".../splitcsv-error/"
            # error_file_base_name is base_filename_for_outputs, row number and suffix added in process_csv

            logger.info(f"Success output key template: {success_key_template}")
            logger.info(f"Error output directory: {error_output_dir} with base name: {base_filename_for_outputs}")

        except IndexError:
            report_error(f"Could not determine output paths for {s3_object_key} due to unexpected key structure.", context)
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
            base_filename_for_outputs, # This is used as error_file_base_name
            s3_object_content,
            context
        )
        
        summary = f"Processed {message_count} HL7 messages from CSV file {s3_object_key}"
        logger.info(summary)
        # Optional: Send success summary to SNS (e.g., if message_count > 0)

    return {"status": "csv processing complete"}
