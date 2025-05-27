
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

# --- HL7 Field Indices (0-indexed) ---
# MSH Segment
MSH_MESSAGE_CONTROL_ID_IDX = 9 # MSH-10
MSH_DATE_TIME_OF_MESSAGE_IDX = 6 # MSH-7

# PID Segment
PID_PATIENT_IDENTIFIER_LIST_IDX = 2 # PID-3
PID_PATIENT_NAME_IDX = 4 # PID-5
PID_DATE_OF_BIRTH_IDX = 6 # PID-7
PID_RACE_IDX = 9 # PID-10
PID_ETHNIC_GROUP_IDX = 21 # PID-22
PID_LAST_UPDATE_DATE_TIME_IDX = 32 # PID-33

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

def validate_and_clean_hl7_coded_field(
    raw_field_value: str,
    valid_codes: set,
    valid_systems: set,
    field_label: str,
    msg_id: str
) -> str:
    """
    Cleans and validates an HL7 coded field (e.g., PID-10 or PID-22).
    Replaces \S\ with ^, splits on ~, checks code/system, and returns cleaned string or ''.
    Emits CloudWatch metrics for rejected values.
    """
    cleaned_field_value = raw_field_value.replace("\\S\\", HL7_COMPONENT_DELIMITER)
    components = cleaned_field_value.split('~')

    valid_components = []
    cloudwatch = boto3.client('cloudwatch')
    for comp in components:
        parts = comp.split(HL7_COMPONENT_DELIMITER)
        if len(parts) < 3:
            logger.warning(
                f"HL7 Validation Warning (Msg ID: {msg_id}): "
                f"{field_label} component missing parts: '{comp}'"
            )
            cloudwatch.put_metric_data(
                Namespace='HL7Validation',
                MetricData=[{
                    'MetricName': 'MalformedComponent',
                    'Dimensions': [{'Name': 'Field', 'Value': field_label}],
                    'Value': 1,
                    'Unit': 'Count'
                }]
            )
            continue
        code, _, system = parts[0], parts[1], parts[2]
        if code in valid_codes and system in valid_systems:
            valid_components.append(comp)
        else:
            logger.warning(
                f"HL7 Validation Warning (Msg ID: {msg_id}): "
                f"{field_label} component invalid: '{comp}'"
            )
            cloudwatch.put_metric_data(
                Namespace='HL7Validation',
                MetricData=[{
                    'MetricName': 'InvalidCodeOrSystem',
                    'Dimensions': [{'Name': 'Field', 'Value': field_label}],
                    'Value': 1,
                    'Unit': 'Count'
                }]
            )

    if valid_components:
        return '~'.join(valid_components)
    else:
        logger.warning(
            f"HL7 Validation Warning (Msg ID: {msg_id}): "
            f"All components in {field_label} are invalid. Clearing field."
        )
        cloudwatch.put_metric_data(
            Namespace='HL7Validation',
            MetricData=[{
                'MetricName': 'AllInvalidCleared',
                'Dimensions': [{'Name': 'Field', 'Value': field_label}],
                'Value': 1,
                'Unit': 'Count'
            }]
        )
        return ''

def _clean_pid_segment(fields: list, hl7_message_id: str) -> list:
    """
    Cleans and validates fields within a PID segment.
    """
    # PID-33 (Last Update Date/Time)
    if len(fields) > PID_LAST_UPDATE_DATE_TIME_IDX:
        pid_33_value = fields[PID_LAST_UPDATE_DATE_TIME_IDX].strip()
        if pid_33_value and not is_valid_hl7_datetime(pid_33_value):
            logger.warning(
                f"HL7 Validation Warning (Msg ID: {hl7_message_id}): "
                f"PID-33 (Last Update Date/Time) contains invalid non-datetime value. "
                f"Original value: '{pid_33_value}'. Setting to empty."
            )
            fields[PID_LAST_UPDATE_DATE_TIME_IDX] = ''

    # PID-3 (Patient Identifier List)
    if len(fields) > PID_PATIENT_IDENTIFIER_LIST_IDX:
        pid_3_value = fields[PID_PATIENT_IDENTIFIER_LIST_IDX].strip()
        if not pid_3_value:
            logger.warning(
                f"HL7 Validation Warning (Msg ID: {hl7_message_id}): "
                f"PID-3 (Patient Identifier List) is empty. This field is typically required."
            )

    # PID-5 (Patient Name)
    if len(fields) > PID_PATIENT_NAME_IDX:
        pid_5_value = fields[PID_PATIENT_NAME_IDX].strip()
        if not pid_5_value or HL7_COMPONENT_DELIMITER not in pid_5_value:
            logger.warning(
                f"HL7 Validation Warning (Msg ID: {hl7_message_id}): "
                f"PID-5 (Patient Name) is missing or malformed. Value: '{pid_5_value}'"
            )
            
    # PID-7 (Date of Birth)
    if len(fields) > PID_DATE_OF_BIRTH_IDX and fields[PID_DATE_OF_BIRTH_IDX].strip():
        pid_7_value = fields[PID_DATE_OF_BIRTH_IDX].strip()
        if not is_valid_hl7_datetime(pid_7_value):
                logger.warning(
                f"HL7 Validation Warning (Msg ID: {hl7_message_id}): "
                f"PID-7 (Date of Birth) seems malformed/invalid. "
                f"Value: '{pid_7_value}'. Consider correcting source data."
            )

    # PID-10 (Race) validation
    if len(fields) > PID_RACE_IDX and fields[PID_RACE_IDX].strip():
        fields[PID_RACE_IDX] = validate_and_clean_hl7_coded_field(
            raw_field_value=fields[PID_RACE_IDX],
            valid_codes={"1002-5", "2028-9", "2054-5", "2076-8", "2106-3", "2131-1", "UNK", "REF"},
            valid_systems={"CDCREC", "HL70005"},
            field_label="PID-10 (Race)",
            msg_id=hl7_message_id
        )

    # PID-22 (Ethnic Group) validation
    if len(fields) > PID_ETHNIC_GROUP_IDX and fields[PID_ETHNIC_GROUP_IDX].strip():
        fields[PID_ETHNIC_GROUP_IDX] = validate_and_clean_hl7_coded_field(
            raw_field_value=fields[PID_ETHNIC_GROUP_IDX],
            valid_codes={"2135-2", "2186-5", "UNK", "REF"},
            valid_systems={"CDCREC", "HL70189"},
            field_label="PID-22 (Ethnic Group)",
            msg_id=hl7_message_id
        )
    return fields

def _clean_msh_segment(fields: list, hl7_message_id: str) -> list:
    """
    Cleans and validates fields within an MSH segment.
    """
    # MSH-7 (Date/Time Of Message) validation
    if len(fields) > MSH_DATE_TIME_OF_MESSAGE_IDX and fields[MSH_DATE_TIME_OF_MESSAGE_IDX].strip():
        msh_7_value = fields[MSH_DATE_TIME_OF_MESSAGE_IDX].strip()
        if not is_valid_hl7_datetime(msh_7_value):
            logger.warning(
                f"HL7 Validation Warning (Msg ID: {hl7_message_id}): "
                f"MSH-7 (Date/Time Of Message) seems malformed/invalid. "
                f"Value: '{msh_7_value}'. Consider correcting source data."
            )
    return fields

# Map segment IDs to their cleaning functions
SEGMENT_CLEANERS = {
    'PID': _clean_pid_segment,
    'MSH': _clean_msh_segment,
    # Add other segment cleaning functions here as needed
}

def clean_hl7_segment(segment: str, hl7_message_id: str = "N/A") -> str:
    """
    Cleans specific HL7 segment fields based on known compliance issues.
    Logs warnings for violations. Dispatches to specific cleaners based on segment ID.
    """
    segment_id = segment[:3]
    fields = segment.split(HL7_FIELD_DELIMITER)

    logger.info(f"Msg ID: {hl7_message_id}: Processing {segment_id} segment.") # Changed to debug

    cleaner_func = SEGMENT_CLEANERS.get(segment_id)
    if cleaner_func:
        logger.info(f"Cleaner for {segment_id} exists.") # Changed to debug
        cleaned_fields = cleaner_func(fields, hl7_message_id)
        return HL7_FIELD_DELIMITER.join(cleaned_fields)
    else:
        # If no specific cleaner, return the original segment (or implement default cleaning)
        logger.info(f"Cleaner for {segment_id} does not exist.") # Changed to debug
        return segment

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
    raw_message_parts = content.strip().split(HL7_MESSAGE_SEPARATOR)

    for i, msg_body_part in enumerate(raw_message_parts):
        if not msg_body_part.strip():
            continue

        hl7_message_str = HL7_MESSAGE_SEPARATOR + msg_body_part.strip()
        
        cleaned_segments = []
        message_segments = re.split(r'[\r\n]+', hl7_message_str.strip())
        
        # Extract MSH-10 for logging if available, otherwise use index
        message_id_for_log = f"Message {i+1} from DAT"
        if len(message_segments) > 0 and message_segments[0].startswith('MSH'):
            msh_fields = message_segments[0].split(HL7_FIELD_DELIMITER)
            if len(msh_fields) > MSH_MESSAGE_CONTROL_ID_IDX and msh_fields[MSH_MESSAGE_CONTROL_ID_IDX].strip():
                message_id_for_log = msh_fields[MSH_MESSAGE_CONTROL_ID_IDX].strip()

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

def _is_valid_s3_key_for_processing(s3_object_key: str) -> bool:
    """
    Performs initial validation of an S3 object key to determine if it should be processed.
    """
    if any(f"/{subdir}/" in s3_object_key for subdir in PROCESSED_SUBDIRS):
        logger.info(f"Skipping already-processed file: {s3_object_key}")
        return False

    s3_key_components = s3_object_key.split('/')
    if len(s3_key_components) < 4:
        logger.warning(f"Unexpected S3 key format (too few components): {s3_object_key}. Skipping.")
        return False
    if s3_key_components[-2] != INCOMING_DIR_NAME:
        logger.warning(
            f"S3 key does not have '{INCOMING_DIR_NAME}' as the expected parent directory "
            f"before the filename: {s3_object_key}. Skipping."
        )
        return False
    if not s3_object_key.endswith(DAT_FILE_EXTENSION):
        logger.info(f"Skipping non-{DAT_FILE_EXTENSION} file: {s3_object_key}")
        return False
    return True

def _determine_output_paths(s3_object_key: str) -> tuple[str, str, str]:
    """
    Determines the base output path, extracted username, and output key template for S3.
    Returns (base_output_path, extracted_username, output_key_template).
    """
    s3_key_components = s3_object_key.split('/')
    site_path_components = s3_key_components[:-3]
    extracted_username = s3_key_components[-3]
    base_output_path = '/'.join(site_path_components + [extracted_username])
    original_file_name = os.path.basename(s3_object_key)
    original_file_name_without_ext = original_file_name.rsplit('.', 1)[0]
    split_output_prefix = f"{base_output_path}/{PROCESSED_SUBDIRS[1]}/" # Using "splitdat"
    output_key_template = f"{split_output_prefix}{extracted_username}_{original_file_name_without_ext}_{{}}.{OUTPUT_FILE_EXTENSION}"
    return base_output_path, extracted_username, output_key_template

def _process_s3_record(record: dict, s3_client: boto3.client, context) -> None:
    """
    Processes a single S3 event record, handling content retrieval and processing.
    """
    s3_bucket_name = record['s3']['bucket']['name']
    s3_object_key = record['s3']['object']['key']

    if not _is_valid_s3_key_for_processing(s3_object_key):
        return

    # Determine Output Paths
    try:
        _, _, output_key_template = _determine_output_paths(s3_object_key)
    except Exception as e:
        error_message = f"Failed to determine output paths for {s3_object_key}: {e}\n{traceback.format_exc()}"
        report_error(error_message, context)
        return

    # S3 Object Retrieval
    try:
        s3_object_content = get_s3_object_content(s3_client, s3_bucket_name, s3_object_key, context)
    except RuntimeError: # get_s3_object_content already reported the error
        return

    # Process .dat Content
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

def lambda_handler(event, context):
    logger.info("Received event: %s", json.dumps(event))
    s3_client = boto3.client('s3')

    for record in event['Records']:
        _process_s3_record(record, s3_client, context)

    return {"status": "dat processing complete"}
