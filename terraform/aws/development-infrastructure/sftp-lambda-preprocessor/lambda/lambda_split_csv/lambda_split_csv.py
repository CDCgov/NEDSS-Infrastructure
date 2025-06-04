
import boto3
import os
# import uuid # No longer needed
import time
import logging
import json
import traceback
import csv
import io
# import hashlib # No longer needed
from datetime import datetime
import urllib.parse

# --- Configuration Constants ---
PROCESSED_SUBDIRS = ["splitcsv", "splitdat", "splitobr"]
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
                Subject=f"Lambda Error in {context.function_name}",
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
    The message_id_for_msh is for MSH-10.
    """
    try:
        # Ensure all required date fields are present and not empty before stripping
        if not row.get('TestDate') or not row.get('DateOfBirth'):
            missing_fields = []
            if not row.get('TestDate'): missing_fields.append('TestDate')
            if not row.get('DateOfBirth'): missing_fields.append('DateOfBirth')
            raise KeyError(f"Missing or empty required date field(s) in CSV row: {', '.join(missing_fields)}")

        msh_timestamp = datetime.strptime(row['TestDate'].strip(), "%m/%d/%Y").strftime("%Y%m%d%H%M")
        dob = datetime.strptime(row['DateOfBirth'].strip(), "%m/%d/%Y").strftime("%Y%m%d")
    except KeyError as e: # Should be caught by the check above, but as a fallback
        raise ValueError(f"Missing expected date field in CSV row: {e}")
    except ValueError as e: # Catches issues from strptime (empty string after strip, wrong format)
        raise ValueError(f"Invalid date format in CSV row (e.g., TestDate='{row.get('TestDate')}', DateOfBirth='{row.get('DateOfBirth')}'): {e}")

    accession_raw = row.get('AccessionNumber', '').strip()
    if not accession_raw:
        raise ValueError(f"Missing or empty AccessionNumber in row for MSH ID {message_id_for_msh}")
    accession = escape_hl7(accession_raw)

    try:
        resulted_test_id = row['ResultedTestID']
        resulted_test_name = escape_hl7(row['ResultedTestName'])
        patient_id = row['Patient_ID']
        pt_last_name = escape_hl7(row['PtLastName'])
        pt_first_name = escape_hl7(row['PtFirstName'])
        sex = row['Sex']
        sending_facility = escape_hl7(row['SendingFacility'])
        test_result = escape_hl7(row['TestResult'])

        # Check for essential non-date fields that might be empty after stripping
        if not resulted_test_id.strip(): raise KeyError('ResultedTestID is empty')
        if not patient_id.strip(): raise KeyError('Patient_ID is empty')

    except KeyError as e:
        raise ValueError(f"Missing or empty required CSV column in row for MSH ID {message_id_for_msh}: {e}")

    obr4 = f"{resulted_test_id.strip()}^{resulted_test_name}" # Ensure IDs are stripped if they are part of OBR-4

    return "\n".join([
        f"MSH|^~\\&|SFTP_APP|{sending_facility}|ELR_RECEIVER|VI_DOH|{msh_timestamp}||ORU^R01|{message_id_for_msh}|P|2.5.1",
        f"PID|||{patient_id.strip()}||{pt_last_name}^{pt_first_name}||{dob}|{sex}",
        "ORC|RE||||||||",
        f"OBR|1|{patient_id.strip()}|{accession}|{obr4}|||{msh_timestamp}", # OBR-2 (Placer Order) uses patient_id in this example
        f"OBX|1|TX|{obr4}||{test_result}||||||F"
    ])

def get_s3_object_content(s3_client: boto3.client, bucket_name: str, key: str, context) -> str:
    s3_object_content = None
    for attempt_num in range(3):
        try:
            obj = s3_client.get_object(Bucket=bucket_name, Key=key)
            s3_object_content = obj['Body'].read().decode('utf-8-sig') # Use utf-8-sig to handle potential BOM
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
    output_key_template: str, # Expects one placeholder for sequence number
    csv_content: str,
    context
) -> int:
    """
    Processes CSV content, generates HL7 messages, and uploads them to S3
    using sequential numbering for output files.
    """
    # io.StringIO expects a string, not bytes
    csv_file = io.StringIO(csv_content)
    
    # Sniff to detect dialect, especially delimiter, if not standard comma
    try:
        dialect = csv.Sniffer().sniff(csv_file.read(2048)) # Read a sample
        csv_file.seek(0) # Rewind
        csv_reader = csv.DictReader(csv_file, dialect=dialect)
    except csv.Error:
        logger.warning("CSV Sniffer could not determine dialect. Assuming comma delimiter and standard format.")
        csv_file.seek(0) # Rewind
        csv_reader = csv.DictReader(csv_file)


    if not csv_reader.fieldnames:
        logger.error("CSV file has no field names (headers). Cannot process.")
        report_error("CSV file has no field names (headers). Cannot process.", context)
        return 0
        
    # Strip whitespace from field names to prevent issues with `row['FieldName']`
    csv_reader.fieldnames = [name.strip() for name in csv_reader.fieldnames]
    logger.info(f"CSV Headers: {csv_reader.fieldnames}")


    processed_message_count = 0
    # `i` is the 0-based row index from enumerate. `row_number` will be 1-based for filenames.
    for i, row in enumerate(csv_reader):
        row_number = i + 1
        try:
            # Clean each value in the row (strip whitespace)
            cleaned_row = {key.strip(): str(value).strip() if value is not None else '' for key, value in row.items()}

            # MSH-10 Message Control ID can still be complex and unique per message if desired
            # Using a combination of available fields; ensure these fields exist or handle gracefully
            msh_patient_id = cleaned_row.get('Patient_ID', f'UnknownPID{row_number}')
            msh_test_id = cleaned_row.get('ResultedTestID', f'UnknownTest{row_number}')
            message_id_for_msh = f"{msh_patient_id}_{msh_test_id}_{row_number}" # Use row_number for uniqueness part

            hl7_message = generate_hl7_message_from_csv_row(cleaned_row, message_id_for_msh)
            
            # Use 1-based sequential number for the filename part
            output_s3_key = output_key_template.format(row_number)

            logger.info(f"Writing HL7 message for CSV row {row_number} (MSH ID: {message_id_for_msh}) to {output_s3_key}")
            s3_client.put_object(
                Bucket=s3_bucket_name,
                Key=output_s3_key,
                Body=hl7_message.encode('utf-8') # HL7 messages usually ASCII or UTF-8
            )
            processed_message_count += 1
        except ValueError as ve: # Catch errors from generate_hl7_message_from_csv_row
            error_msg = f"Data validation error for CSV row {row_number}: {ve}. Row data (first 100 chars): {str(row)[:100]}"
            report_error(error_msg, context)
            logger.error(error_msg)
            continue # Skip to the next row
        except Exception as e:
            error_msg = f"Failed to process CSV row {row_number}: {e}\n{traceback.format_exc()}. Row data (first 100 chars): {str(row)[:100]}"
            report_error(error_msg, context)
            logger.error(error_msg) # Log the error for this specific row
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

        if any(f"/{subdir}/" in s3_object_key for subdir in PROCESSED_SUBDIRS):
            logger.info(f"Skipping already-processed file: {s3_object_key}")
            continue

        s3_key_components = s3_object_key.split('/')
        if len(s3_key_components) < 4:
            logger.warning(f"Unexpected S3 key format (too few components): {s3_object_key}. Skipping.")
            continue
        if s3_key_components[-2] != INCOMING_DIR_NAME:
            logger.warning(
                f"S3 key does not have '{INCOMING_DIR_NAME}' as the expected parent directory "
                f"before the filename: {s3_object_key}. Skipping."
            )
            continue
        if not s3_object_key.lower().endswith(CSV_FILE_EXTENSION): # Use .lower() for case-insensitivity
            logger.info(f"Skipping non-{CSV_FILE_EXTENSION} file: {s3_object_key}")
            continue

        try:
            site_path_components = s3_key_components[:-3]
            extracted_username = s3_key_components[-3]
            base_output_path = '/'.join(site_path_components + [extracted_username])
            original_file_name = os.path.basename(s3_object_key)
            original_file_name_without_ext = original_file_name.rsplit('.', 1)[0]
            
            # Output to "splitcsv" directory, PROCESSED_SUBDIRS[0]
            split_output_prefix = f"{base_output_path}/{PROCESSED_SUBDIRS[0]}/"
            # Template expects one placeholder for the sequence number
            output_key_template = f"{split_output_prefix}{extracted_username}_{original_file_name_without_ext}_{{}}.{OUTPUT_FILE_EXTENSION}"
            logger.info(f"Output key template for CSV-generated HL7 files: {output_key_template}")
        except IndexError:
            report_error(f"Could not determine output paths for {s3_object_key} due to unexpected key structure.", context)
            continue


        try:
            s3_object_content = get_s3_object_content(s3_client, s3_bucket_name, s3_object_key, context)
        except RuntimeError: # Raised by get_s3_object_content on failure
            continue # Error already reported by get_s3_object_content

        # Process CSV Content and Upload HL7 (key_hash_prefix removed)
        message_count = process_csv_content_and_upload_hl7(
            s3_client,
            s3_bucket_name,
            output_key_template,
            s3_object_content,
            context
        )
        
        summary = f"Processed {message_count} HL7 messages from CSV file {s3_object_key}"
        logger.info(summary)
        # Optionally send success summary to SNS
        # if os.environ.get(ERROR_TOPIC_ENV_VAR) and message_count > 0:
        #     sns = boto3.client('sns')
        #     sns.publish(TopicArn=os.environ.get(ERROR_TOPIC_ENV_VAR), Subject="CSV to HL7 Success", Message=summary)

    return {"status": "csv processing complete"}
