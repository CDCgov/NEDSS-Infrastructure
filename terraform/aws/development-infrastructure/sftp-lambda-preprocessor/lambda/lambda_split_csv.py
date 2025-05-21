
import boto3
import os
import uuid
import time
import logging
import json
import traceback
import csv
import io
import hashlib 
from datetime import datetime

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

def generate_hl7_message_from_csv_row(row: dict, message_id: str) -> str:
    """
    Generates an HL7 ORU^R01 message from a single CSV row.
    This logic is adapted from the provided lambda_function.py.
    """
    try:
        msh_timestamp = datetime.strptime(row['TestDate'].strip(), "%m/%d/%Y").strftime("%Y%m%d%H%M")
        dob = datetime.strptime(row['DateOfBirth'].strip(), "%m/%d/%Y").strftime("%Y%m%d")
    except KeyError as e:
        raise ValueError(f"Missing expected date field in CSV row: {e}")
    except ValueError as e:
        raise ValueError(f"Invalid date format in CSV row: {e}")

    accession_raw = row.get('AccessionNumber', '').strip()
    if not accession_raw:
        raise ValueError(f"Missing AccessionNumber in row for message {message_id}")
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
    except KeyError as e:
        raise ValueError(f"Missing expected CSV column in row for message {message_id}: {e}")

    obr4 = f"{resulted_test_id}^{resulted_test_name}"

    return "\n".join([
        f"MSH|^~\\&|SFTP_APP|{sending_facility}|ELR_RECEIVER|VI_DOH|{msh_timestamp}||ORU^R01|{message_id}|P|2.5.1",
        f"PID|||{patient_id}||{pt_last_name}^{pt_first_name}||{dob}|{sex}",
        f"ORC|RE||||||||",
        f"OBR|1|{patient_id}|{accession}|{obr4}|||{msh_timestamp}",
        f"OBX|1|TX|{obr4}||{test_result}||||||F"
    ])

def get_s3_object_content(s3_client: boto3.client, bucket_name: str, key: str, context) -> str:
    """
    Retrieves content from an S3 object with retry logic.
    Raises RuntimeError if object cannot be retrieved after retries.
    """
    s3_object_content = None
    for attempt_num in range(3):
        try:
            obj = s3_client.get_object(Bucket=bucket_name, Key=key)
            s3_object_content = obj['Body'].read().decode('utf-8')
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
    output_key_template: str,
    csv_content: str,
    key_hash_prefix: str,
    context
) -> int:
    """
    Processes CSV content, generates HL7 messages, and uploads them to S3.
    """
    csv_reader = csv.DictReader(io.StringIO(csv_content))
    csv_reader.fieldnames = [name.strip() for name in csv_reader.fieldnames]

    message_count = 0
    for i, row in enumerate(csv_reader):
        try:
            msg_id = f"{row['Patient_ID']}_{row['ResultedTestID']}_{i}"
            hl7_message = generate_hl7_message_from_csv_row(row, msg_id)
            
            output_s3_key = output_key_template.format(f"{key_hash_prefix}_{msg_id}")

            logger.info(f"Writing HL7 message for {msg_id} to {output_s3_key}")
            s3_client.put_object(
                Bucket=s3_bucket_name,
                Key=output_s3_key,
                Body=hl7_message.encode('utf-8')
            )
            message_count += 1
        except ValueError as ve:
            error_msg = f"Data validation error for row {i+1} in CSV: {ve}"
            report_error(error_msg, context)
            logger.error(error_msg)
            continue
        except Exception as e:
            error_msg = f"Failed to process row {i+1} from CSV: {e}\n{traceback.format_exc()}"
            report_error(error_msg, context)
            continue
            
    return message_count


def lambda_handler(event, context):
    logger.info("Received event: %s", json.dumps(event))
    s3_client = boto3.client('s3')

    for record in event['Records']:
        s3_bucket_name = record['s3']['bucket']['name']
        s3_object_key = record['s3']['object']['key']

        # Pre-checks for key format and file type
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
        if not s3_object_key.endswith(CSV_FILE_EXTENSION):
            logger.info(f"Skipping non-{CSV_FILE_EXTENSION} file: {s3_object_key}")
            continue

        # --- Determine Output Paths ---
        site_path_components = s3_key_components[:-3]
        extracted_username = s3_key_components[-3]
        base_output_path = '/'.join(site_path_components + [extracted_username])
        original_file_name = os.path.basename(s3_object_key)
        original_file_name_without_ext = original_file_name.rsplit('.', 1)[0]
        split_output_prefix = f"{base_output_path}/{PROCESSED_SUBDIRS[0]}/"
        output_key_template = f"{split_output_prefix}{extracted_username}_{original_file_name_without_ext}_{{}}.{OUTPUT_FILE_EXTENSION}"

        # Generate a hash prefix for uniqueness, similar to lambda_function.py
        file_key_hash_prefix = hashlib.md5(s3_object_key.encode()).hexdigest()[:8]

        # --- S3 Object Retrieval ---
        try:
            s3_object_content = get_s3_object_content(s3_client, s3_bucket_name, s3_object_key, context)
        except RuntimeError:
            continue

        # --- Process CSV Content and Upload HL7 ---
        message_count = process_csv_content_and_upload_hl7(
            s3_client,
            s3_bucket_name,
            output_key_template,
            s3_object_content,
            file_key_hash_prefix,
            context
        )
        
        summary = f"Processed {message_count} HL7 messages from {s3_object_key}"
        logger.info(summary)
        if os.environ.get(ERROR_TOPIC_ENV_VAR):
            sns = boto3.client('sns')
            sns.publish(TopicArn=os.environ.get(ERROR_TOPIC_ENV_VAR), Subject="CSV to HL7 Success", Message=summary)

    return {"status": "csv processing complete"}
