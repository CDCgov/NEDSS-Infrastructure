
import boto3
import os
import uuid
import time
import logging
import json
import traceback
import re

from datetime import datetime

# --- Configuration Constants ---
PROCESSED_SUBDIRS = ["splitcsv", "splitdat", "splitobr"]
INCOMING_DIR_NAME = "incoming"
OUTPUT_FILE_EXTENSION = "hl7"
ERROR_TOPIC_ENV_VAR = 'ERROR_TOPIC_ARN'
DAT_FILE_EXTENSION = '.dat'
HL7_MESSAGE_SEPARATOR = 'MSH' # Used to split messages within a .dat file
HL7_FIELD_DELIMITER = '|'     # HL7 standard field delimiter
HL7_COMPONENT_DELIMITER = '^' # HL7 standard component delimiter

# --- Logging Setup ---
logger = logging.getLogger()
#logger.setLevel(logging.DEBUG)  # Temporarily set to DEBUG for PID-33 tracing
logger.setLevel(logging.INFO)  # Temporarily set to DEBUG for PID-33 tracing
                               # Temporarily change to DEBUG if you need detailed PID-33 logs.

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
            logger.info(f"Successfully retrieved S3 object {key} on attempt {attempt_num+1}.")
            break
        except s3_client.exceptions.NoSuchKey:
            logger.warning(f"Attempt {attempt_num+1}: Key not found: {key}. Retrying in 1 second.")
            time.sleep(1)
        except Exception as e:
            error_message = f"Error getting S3 object {key} on attempt {attempt_num+1}: {e}\n{traceback.format_exc()}"
            report_error(error_message, context)
            raise # Re-raise for other types of errors immediately

    if s3_object_content is None:
        error_message = f"Failed to retrieve S3 object after 3 attempts: {key}"
        report_error(error_message, context)
        raise RuntimeError(error_message)
    
    return s3_object_content

def write_hl7_message_to_s3(
    s3_client: boto3.client,
    s3_bucket_name: str,
    output_key_template: str,
    hl7_message: str,
    context
) -> None:
    """
    Writes a single HL7 message to S3.
    """
    if not hl7_message.strip(): # Ensure there's content to write
        logger.warning("Skipping write: HL7 message content is empty after processing.")
        return

    output_s3_key = output_key_template.format(uuid.uuid4())
    # IMPORTANT: Do NOT log hl7_message content here due to PHI.
    logger.info(f"Attempting to write HL7 from DAT to S3. Key: {output_s3_key}, Bucket: {s3_bucket_name}.")

    try:
        s3_client.put_object(Bucket=s3_bucket_name, Key=output_s3_key, Body=hl7_message.encode('utf-8'))
        logger.info(f"Successfully wrote HL7 from DAT to {output_s3_key}")
    except Exception as e:
        error_message = (
            f"CRITICAL ERROR: Failed to write HL7 message to {output_s3_key}. "
            f"Error: {e}\n{traceback.format_exc()}"
        )
        report_error(error_message, context)
        raise # Re-raise to ensure the Lambda execution fails for this record if S3 write fails.

def is_valid_hl7_datetime(dt_str: str) -> bool:
    """
    Checks if a string could be a valid HL7 datetime format.
    Handles common HL7 timestamp formats (e.g., YYYYMMDD, YYYYMMDDHHMMSS, YYYYMMDDHHMMSS.SSS).
    Does not handle time zones or complex variations.
    """
    if not dt_str:
        return True # Empty string is often valid for optional datetime fields

    # Remove any fractional seconds or timezone info for basic parsing
    dt_str_clean = dt_str.split('.')[0].split('+')[0].split('-')[0]

    # Try common formats in order of length
    formats = [
        "%Y%m%d%H%M%S",  # YYYYMMDDHHMMSS
        "%Y%m%d%H%M",    # YYYYMMDDHHMM
        "%Y%m%d%H",      # YYYYMMDDHH
        "%Y%m%d",        # YYYYMMDD
    ]

    for fmt in formats:
        try:
            datetime.strptime(dt_str_clean, fmt)
            return True
        except ValueError:
            continue
    return False


def clean_hl7_segment(segment: str, hl7_message_id: str = "N/A") -> str:
    """
    Cleans specific HL7 segment fields based on known compliance issues.
    Logs warnings for violations.
    """
    segment_id = segment[:3]
    fields = segment.split(HL7_FIELD_DELIMITER)

    logger.info(f"Msg ID: {hl7_message_id}: Processing {segment_id} segment.")

    # PID segment validation/cleaning
    if segment_id == 'PID':
        logger.info(f"Msg ID: {hl7_message_id}: Processing PID segment. Field count: {len(fields)}")
        # PID-33 (Last Update Date/Time)
        # It's a timestamp field. 'N' or other non-datetime values are invalid.
        pid_33_idx = 33 # PID-33 is at index 33 (0-indexed)
        if len(fields) > pid_33_idx: # Check if field exists
            pid_33_value = fields[pid_33_idx].strip()
            logger.info(f"Checking PID-33: Index={pid_33_idx}, Value='{pid_33_value}'")
            logger.info(f"Msg ID: {hl7_message_id}, PID-33 raw value: '{pid_33_value}'")

            # Check if it's not empty AND it's not a valid HL7 datetime
            if pid_33_value and not is_valid_hl7_datetime(pid_33_value):
                logger.warning(
                    f"HL7 Validation Warning (Msg ID: {hl7_message_id}): "
                    f"PID-33 (Last Update Date/Time) contains invalid non-datetime value. "
                    f"Original value: '{pid_33_value}'. Setting to empty."
                )
                logger.info(f"PID-33 is invalid, clearing it. Original value: '{pid_33_value}'")
                fields[pid_33_idx] = ''  # Set to empty string
        else:
            logger.info(f"Msg ID: {hl7_message_id}: PID segment does not have PID-33 field.")

        # PID-7 (Date of Birth) format validation

        # PID-3 (Patient Identifier List)
        pid_3_idx = 3
        if len(fields) > pid_3_idx:
            pid_3_value = fields[pid_3_idx].strip()
            if not pid_3_value:
                logger.warning(
                    f"HL7 Validation Warning (Msg ID: {hl7_message_id}): "
                    f"PID-3 (Patient Identifier List) is empty. This field is typically required."
                )

        # PID-5 (Patient Name)
        pid_5_idx = 5
        if len(fields) > pid_5_idx:
            pid_5_value = fields[pid_5_idx].strip()
            if not pid_5_value or '^' not in pid_5_value:
                logger.warning(
                    f"HL7 Validation Warning (Msg ID: {hl7_message_id}): "
                    f"PID-5 (Patient Name) is missing or malformed. Value: '{pid_5_value}'"
                )
        pid_7_idx = 7
        if len(fields) > pid_7_idx and fields[pid_7_idx].strip():
            pid_7_value = fields[pid_7_idx].strip()
            if not is_valid_hl7_datetime(pid_7_value):
                 logger.warning(
                    f"HL7 Validation Warning (Msg ID: {hl7_message_id}): "
                    f"PID-7 (Date of Birth) seems malformed/invalid. "
                    f"Value: '{pid_7_value}'. Consider correcting source data."
                )

    # MSH segment validation/cleaning
    elif segment_id == 'MSH':
        # MSH-7 (Date/Time Of Message) validation
        msh_7_idx = 7
        if len(fields) > msh_7_idx and fields[msh_7_idx].strip():
            msh_7_value = fields[msh_7_idx].strip()
            if not is_valid_hl7_datetime(msh_7_value):
                logger.warning(
                    f"HL7 Validation Warning (Msg ID: {hl7_message_id}): "
                    f"MSH-7 (Date/Time Of Message) seems malformed/invalid. "
                    f"Value: '{msh_7_value}'. Consider correcting source data."
                )

    # Add other segment validations as needed based on common issues

    return HL7_FIELD_DELIMITER.join(fields)

def process_dat_content(
    s3_client: boto3.client,
    s3_bucket_name: str,
    output_key_template: str,
    content: str,
    context
) -> None:
    """
    Splits .dat file content into individual HL7 messages, cleans them, and writes them to S3.
    """
    # Split by 'MSH' to separate HL7 messages that might be concatenated
    # The first 'MSH' will result in an empty string before it if content starts with MSH
    raw_message_parts = content.strip().split(HL7_MESSAGE_SEPARATOR)

    for i, msg_body_part in enumerate(raw_message_parts):
        if not msg_body_part.strip(): # Skip empty parts (e.g., before the first MSH)
            continue

        # Re-add 'MSH' to the beginning of each message part
        hl7_message_str = HL7_MESSAGE_SEPARATOR + msg_body_part.strip()
        
        # --- Apply Cleaning and Validation ---
        cleaned_segments = []
        #message_segments = hl7_message_str.split('\n')
        message_segments = re.split(r'[\r\n]+', hl7_message_str.strip())
        
        # Extract MSH-10 for logging if available, otherwise use index
        message_id_for_log = f"Message {i+1} from DAT"
        if len(message_segments) > 0 and message_segments[0].startswith('MSH'):
            msh_fields = message_segments[0].split(HL7_FIELD_DELIMITER)
            # MSH-10 (Message Control ID) is at index 9 (0-indexed)
            if len(msh_fields) > 9 and msh_fields[9].strip():
                message_id_for_log = msh_fields[9].strip() # Use MSH-10 as identifier

        logger.info(f"Processing HL7 message: {message_id_for_log}")
        for segment in message_segments:
            if segment.strip():
                cleaned_segment = clean_hl7_segment(segment.strip(), hl7_message_id=message_id_for_log)
                cleaned_segments.append(cleaned_segment)
        
        final_hl7_message = '\n'.join(cleaned_segments)

        write_hl7_message_to_s3(
            s3_client,
            s3_bucket_name,
            output_key_template,
            final_hl7_message,
            context
        )

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
        if not s3_object_key.endswith(DAT_FILE_EXTENSION):
            logger.info(f"Skipping non-{DAT_FILE_EXTENSION} file: {s3_object_key}")
            continue

        # --- Determine Output Paths ---
        site_path_components = s3_key_components[:-3]
        extracted_username = s3_key_components[-3]
        base_output_path = '/'.join(site_path_components + [extracted_username])
        original_file_name = os.path.basename(s3_object_key)
        original_file_name_without_ext = original_file_name.rsplit('.', 1)[0]
        split_output_prefix = f"{base_output_path}/{PROCESSED_SUBDIRS[1]}/" # Using "splitdat"
        output_key_template = f"{split_output_prefix}{extracted_username}_{original_file_name_without_ext}_{{}}.{OUTPUT_FILE_EXTENSION}"

        # --- S3 Object Retrieval ---
        try:
            s3_object_content = get_s3_object_content(s3_client, s3_bucket_name, s3_object_key, context)
        except RuntimeError:
            # get_s3_object_content already reported the error
            continue # Move to the next S3 record

        # --- Process .dat Content ---
        try:
            process_dat_content(
                s3_client,
                s3_bucket_name,
                output_key_template,
                s3_object_content,
                context
            )
        except Exception as e:
            error_message = f"Failed to process DAT content for {s3_object_key}: {e}\n{traceback.format_exc()}"
            report_error(error_message, context)
            # Continue to the next S3 record if processing fails for one
            continue

    return {"status": "dat processing complete"}
