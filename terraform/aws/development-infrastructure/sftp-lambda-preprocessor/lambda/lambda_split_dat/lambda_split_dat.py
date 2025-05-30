
import boto3
import os
import uuid
import time
import logging
import json
import traceback
import re
import hl7  # <-- Import the python-hl7 library
import urllib.parse # Add this import

from datetime import datetime
from botocore.exceptions import ClientError

# --- Configuration Constants ---
PROCESSED_SUBDIRS = ["splitcsv", "splitdat", "splitobr"]
INCOMING_DIR_NAME = "incoming"
OUTPUT_FILE_EXTENSION = "hl7"
ERROR_TOPIC_ENV_VAR = 'ERROR_TOPIC_ARN'
DAT_FILE_EXTENSION = '.dat'
HL7_MESSAGE_SEPARATOR = 'MSH' # Used to split messages within a .dat file
# HL7 Delimiters are now typically handled by the library, but needed for MSH check
HL7_FIELD_DELIMITER = '|'
HL7_COMPONENT_DELIMITER = '^'
MAX_S3_RETRIES = 3
S3_RETRY_DELAY_SECONDS = 2

# --- HL7 Field Indices (0-indexed, still useful for accessing via library) ---
# MSH Segment
MSH_MESSAGE_CONTROL_ID_IDX = 9 # MSH-10
MSH_DATE_TIME_OF_MESSAGE_IDX = 6 # MSH-7

# PID Segment
PID_PATIENT_IDENTIFIER_LIST_IDX = 2 # PID-3
PID_PATIENT_NAME_IDX = 4 # PID-5
PID_DATE_OF_BIRTH_IDX = 6 # PID-7
PID_RACE_IDX = 10 # PID-10
PID_ETHNIC_GROUP_IDX = 21 # PID-22
PID_LAST_UPDATE_DATE_TIME_IDX = 33 # PID-33

# --- HL7 Validation Sets ---
VALID_RACE_CODES = {"1002-5", "2028-9", "2054-5", "2076-8", "2106-3", "2131-1", "UNK", "REF"}
VALID_RACE_SYSTEMS = {"CDCREC", "HL70005"}
VALID_ETHNIC_CODES = {"2135-2", "2186-5", "UNK", "REF"}
VALID_ETHNIC_SYSTEMS = {"CDCREC", "HL70189"}

# --- Logging Setup ---
logger = logging.getLogger()
logger.setLevel(logging.INFO)
# only set debug level on synthetic/test data
# logger.setLevel(logging.DEBUG)

# --- AWS Boto3 Clients (Initialized globally for reuse) ---
s3_client = boto3.client('s3')
sns_client = boto3.client('sns')
cloudwatch_client = boto3.client('cloudwatch')

# --- Helper Functions (report_error, get_s3_object_content, write_hl7_message_to_s3 - Unchanged) ---

def report_error(error_msg: str, context) -> None:
    """
    Reports an error by logging it and attempting to publish to an SNS topic.
    """
    logger.error(error_msg)
    try:
        topic_arn = os.environ.get(ERROR_TOPIC_ENV_VAR)
        if topic_arn:
            sns_client.publish(
                TopicArn=topic_arn,
                Subject=f"Lambda Error in {context.function_name}",
                Message=error_msg
            )
    except Exception as sns_error:
        logger.warning("SNS publish failed: %s", str(sns_error))

def get_s3_object_content(bucket_name: str, key: str, context) -> str:
    """
    Retrieves content from an S3 object with retry logic.
    Raises RuntimeError if object cannot be retrieved after retries.
    """
    s3_object_content = None
    for attempt_num in range(MAX_S3_RETRIES):
        try:
            obj = s3_client.get_object(Bucket=bucket_name, Key=key) # key will be decoded
            s3_object_content = obj['Body'].read().decode('utf-8')
            logger.info(f"Successfully retrieved S3 object {key} on attempt {attempt_num+1}.")
            return s3_object_content # Return immediately on success
        except ClientError as e:
            error_code = e.response.get("Error", {}).get("Code")
            if error_code in ['NoSuchKey', 'SlowDown', 'InternalError', 'RequestTimeout', 'ThrottlingException']:
                logger.warning(
                    f"Attempt {attempt_num+1}: S3 ClientError '{error_code}' for {key}. "
                    f"Retrying in {S3_RETRY_DELAY_SECONDS} second(s)."
                )
                time.sleep(S3_RETRY_DELAY_SECONDS)
            else:
                error_message = f"Unrecoverable S3 ClientError getting {key}: {e}\n{traceback.format_exc()}"
                report_error(error_message, context)
                raise RuntimeError(error_message) from e
        except Exception as e:
            error_message = f"Error getting S3 object {key} on attempt {attempt_num+1}: {e}\n{traceback.format_exc()}"
            report_error(error_message, context)
            raise RuntimeError(error_message) from e

    error_message = f"Failed to retrieve S3 object after {MAX_S3_RETRIES} attempts: {key}"
    report_error(error_message, context)
    raise RuntimeError(error_message)


def write_hl7_message_to_s3(
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
        raise

# --- HL7 Cleaning/Validation Functions (Updated) ---

def is_valid_hl7_datetime(dt_str: str) -> bool:
    """
    Checks if a string could be a valid HL7 datetime format.
    Handles common HL7 timestamp formats and attempts to strip timezones.
    """
    if not dt_str:
        return True

    dt_str_clean = re.sub(r'[+-]\d{4}$', '', dt_str)
    dt_str_clean = dt_str_clean.split('.')[0]

    formats = ["%Y%m%d%H%M%S", "%Y%m%d%H%M", "%Y%m%d%H", "%Y%m%d"]

    for fmt in formats:
        try:
            datetime.strptime(dt_str_clean, fmt)
            logger.debug(f"is_valid_hl7_datetime: Successfully parsed '{dt_str}' as '{fmt}'")
            return True
        except ValueError:
            continue
    logger.debug(f"is_valid_hl7_datetime: Failed to parse '{dt_str}' with any known HL7 datetime format.")
    return False


def validate_and_clean_hl7_coded_field(
    raw_field_value: str,
    valid_codes: set,
    valid_systems: set,
    field_label: str,
    msg_id: str
) -> str:
    """
    Cleans and validates an HL7 coded field string.
    Replaces \S\ with ^, splits on ~, checks code/system, and returns cleaned string or ''.
    """
    if not raw_field_value:
        return ''

    logger.info(f"[{msg_id}] {field_label}: checking for \\S\\ replacement")
    logger.debug(f"[{msg_id}] {field_label}: Raw value before \\S\\ replacement: '{raw_field_value}'")
    # FIX: Use r"..." + "\\" to avoid SyntaxWarning
    cleaned_field_value = raw_field_value.replace(r"\S" + "\\", HL7_COMPONENT_DELIMITER)
    logger.debug(f"[{msg_id}] {field_label}: Value after \\S\\ replacement: '{cleaned_field_value}'")

    components = cleaned_field_value.split('~')
    valid_components = []

    for comp in components:
        parts = comp.split(HL7_COMPONENT_DELIMITER)
        logger.info(f"[{msg_id}] {field_label}: Processing component , split into parts")
        logger.debug(f"[{msg_id}] {field_label}: Processing component '{comp}', split into parts: {parts}")
        if len(parts) < 3:
            logger.warning(f"HL7 Validation Warning (Msg ID: {msg_id}): {field_label} component missing parts: '{comp}'")
            cloudwatch_client.put_metric_data(
                Namespace='HL7Validation',
                MetricData=[{'MetricName': 'MalformedComponent', 'Dimensions': [{'Name': 'Field', 'Value': field_label}], 'Value': 1, 'Unit': 'Count'}]
            )
            continue

        code, _, system = parts[0].strip(), parts[1].strip(), parts[2].strip()
        logger.info(f"[{msg_id}] {field_label}: Component -> Code , System")
        logger.debug(f"[{msg_id}] {field_label}: Component '{comp}' -> Code:'{code}', System:'{system}'")

        if code in valid_codes and system in valid_systems:
            valid_components.append(comp)
            logger.info(f"[{msg_id}] {field_label}: Component is VALID.")
            logger.debug(f"[{msg_id}] {field_label}: Component '{comp}' is VALID.")
        else:
            logger.warning(f"HL7 Validation Warning (Msg ID: {msg_id}): {field_label} component invalid")
            logger.debug(f"HL7 Validation Warning (Msg ID: {msg_id}): {field_label} component invalid: '{comp}'")
            cloudwatch_client.put_metric_data(
                Namespace='HL7Validation',
                MetricData=[{'MetricName': 'InvalidCodeOrSystem', 'Dimensions': [{'Name': 'Field', 'Value': field_label}], 'Value': 1, 'Unit': 'Count'}]
            )

    if valid_components:
        final_value = '~'.join(valid_components)
        logger.info(f"[{msg_id}] {field_label}: Valid components found. Returning")
        logger.debug(f"[{msg_id}] {field_label}: Valid components found. Returning: '{final_value}'")
        return final_value
    else:
        logger.warning(f"HL7 Validation Warning (Msg ID: {msg_id}): All components in {field_label} are invalid. Clearing field.")
        cloudwatch_client.put_metric_data(
            Namespace='HL7Validation',
            MetricData=[{'MetricName': 'AllInvalidCleared', 'Dimensions': [{'Name': 'Field', 'Value': field_label}], 'Value': 1, 'Unit': 'Count'}]
        )
        logger.info(f"[{msg_id}] {field_label}: No valid components. Returning empty string.")
        return ''

def get_field_value(segment: hl7.Segment, index: int) -> str:
    """Safely retrieves a field value as a string, returning '' if out of bounds."""
    try:
        # Access the field; HL7 library returns a Field object.
        # Use str() to get its string representation.
        # The library uses 1-based indexing for fields when using `segment[index]`,
        # but the underlying list is 0-based. Let's use 0-based to match our constants.
        # IMPORTANT: `python-hl7` internally uses 1-based indexing in many places.
        # Let's check `segment[index+1]` for 1-based or `str(segment[index])` for 0-based.
        # `python-hl7` `Segment` acts like a list (0-based). So `segment[index]` is correct.
        if index < len(segment):
             return str(segment[index])
        return ''
    except IndexError:
        return ''

def set_field_value(segment: hl7.Segment, index: int, value: str):
    """Safely sets a field value, growing the segment if necessary."""
    while len(segment) <= index:
        segment.append('') # Append empty fields until the index is reachable
    segment[index] = value


def clean_hl7_message(msg: hl7.Message, msg_id: str) -> hl7.Message:
    """
    Cleans specific fields within an HL7 message object.
    """
    # --- MSH Cleaning ---
    try:
        msh = msg.segment('MSH')
        msh_7_value = get_field_value(msh, MSH_DATE_TIME_OF_MESSAGE_IDX)
        if msh_7_value and not is_valid_hl7_datetime(msh_7_value):
            logger.warning(f"HL7 Validation Warning (Msg ID: {msg_id}): MSH-7 seems malformed. Value: '{msh_7_value}'.")
        logger.info(f"[{msg_id}]: MSH-7")
        logger.debug(f"[{msg_id}]: MSH-7: '{msh_7_value}'")
    except KeyError:
        logger.warning(f"[{msg_id}]: MSH segment not found.")

    # --- PID Cleaning ---
    try:
        pid = msg.segment('PID') # Gets the first PID segment

        # PID-33
        pid_33_value = get_field_value(pid, PID_LAST_UPDATE_DATE_TIME_IDX)
        if pid_33_value and not is_valid_hl7_datetime(pid_33_value):
            logger.warning(f"HL7 Validation Warning (Msg ID: {msg_id}): PID-33 invalid. Original: '{pid_33_value}'. Clearing.")
            set_field_value(pid, PID_LAST_UPDATE_DATE_TIME_IDX, '')
        logger.info(f"[{msg_id}]: PID-33 procession...")
        logger.debug(f"[{msg_id}]: PID-33: '{get_field_value(pid, PID_LAST_UPDATE_DATE_TIME_IDX)}'")

        # PID-3 & PID-5 & PID-7 (Checks)
        if not get_field_value(pid, PID_PATIENT_IDENTIFIER_LIST_IDX):
             logger.warning(f"HL7 Validation Warning (Msg ID: {msg_id}): PID-3 is empty.")
        if not get_field_value(pid, PID_PATIENT_NAME_IDX):
             logger.warning(f"HL7 Validation Warning (Msg ID: {msg_id}): PID-5 is empty.")
        pid_7_value = get_field_value(pid, PID_DATE_OF_BIRTH_IDX)
        if pid_7_value and not is_valid_hl7_datetime(pid_7_value):
             logger.warning(f"HL7 Validation Warning (Msg ID: {msg_id}): PID-7 seems malformed. Value: '{pid_7_value}'.")

        # PID-10 (Race)
        raw_pid_10 = get_field_value(pid, PID_RACE_IDX)
        if raw_pid_10:
            cleaned_pid_10 = validate_and_clean_hl7_coded_field(raw_pid_10, VALID_RACE_CODES, VALID_RACE_SYSTEMS, "PID-10 (Race)", msg_id)
            set_field_value(pid, PID_RACE_IDX, cleaned_pid_10)
            logger.info(f"[{msg_id}]: PID-10 Cleaned")
            logger.debug(f"[{msg_id}]: PID-10: Original='{raw_pid_10}', Cleaned='{cleaned_pid_10}'")

        # PID-22 (Ethnic Group)
        raw_pid_22 = get_field_value(pid, PID_ETHNIC_GROUP_IDX)
        if raw_pid_22:
            cleaned_pid_22 = validate_and_clean_hl7_coded_field(raw_pid_22, VALID_ETHNIC_CODES, VALID_ETHNIC_SYSTEMS, "PID-22 (Ethnic Group)", msg_id)
            set_field_value(pid, PID_ETHNIC_GROUP_IDX, cleaned_pid_22)
            logger.info(f"[{msg_id}]: PID-22(Ethnic Group) Cleaned")
            logger.debug(f"[{msg_id}]: PID-22: Original='{raw_pid_22}', Cleaned='{cleaned_pid_22}'")

    except KeyError:
        logger.warning(f"[{msg_id}]: PID segment not found.")

    # Add other segment cleaners here if needed
    return msg


def process_dat_content(
    s3_bucket_name: str,
    output_key_template: str,
    content: str,
    context
) -> None:
    """
    Splits .dat file content, parses with HL7 lib, cleans, and writes to S3.
    """
    logger.info("Starting to process DAT file content with HL7 library.")
    raw_message_parts = content.strip().split(HL7_MESSAGE_SEPARATOR)

    for i, msg_body_part in enumerate(raw_message_parts):
        if not msg_body_part.strip():
            logger.info(f"Skipping empty message part {i}.")
            continue

        hl7_message_str = HL7_MESSAGE_SEPARATOR + msg_body_part.strip()
        logger.info(f"Extracted raw HL7 message part {i+1}.")
        logger.debug(f"Extracted raw HL7 message part {i+1}. Starting with: '{hl7_message_str[:100]}...'")

        try:
            # Parse the message using the hl7 library
            # Use `hl7.parse(..., find_groups=False)` if group parsing isn't needed/causes issues.
            parsed_message = hl7.parse(hl7_message_str)

            # Get MSH-10 for logging
            try:
                 message_id_for_log = str(parsed_message.segment('MSH')[MSH_MESSAGE_CONTROL_ID_IDX]) or f"Message {i+1} (No MSH-10)"
            except (KeyError, IndexError):
                 message_id_for_log = f"Message {i+1} (MSH Error)"
            logger.info(f"Successfully parsed. Processing HL7 message with ID: {message_id_for_log}")

            # Clean the parsed message object
            cleaned_message = clean_hl7_message(parsed_message, message_id_for_log)

            # Serialize the cleaned message back to a string (uses \r by default)
            # Use .replace('\r', '\n') if you strictly need \n separators.
            final_hl7_message = str(cleaned_message)
            logger.info(f"[{message_id_for_log}]: Final cleaned HL7 message  XXXXXXX")
            logger.debug(f"[{message_id_for_log}]: Final cleaned HL7 message (first 200 chars): '{final_hl7_message[:200]}...'")

            # Write to S3
            write_hl7_message_to_s3(
                s3_bucket_name,
                output_key_template,
                final_hl7_message,
                context
            )

        except hl7.exceptions.HL7Exception as e:
            error_message = (
                f"HL7 Parsing FAILED for message part {i+1}. Error: {e}\n"
                f"Content (first 200 chars): '{hl7_message_str[:200]}...'\n"
                f"{traceback.format_exc()}"
            )
            report_error(error_message, context)
            # Decide if you want to raise this to stop all processing or continue.
            # Continuing might be better if one bad message shouldn't stop others.
            # Raising is better if the whole file must be processed or nothing.
            # We will continue for now, but add a warning.
            logger.error(f"Skipping message part {i+1} due to parsing error.")
            continue # Move to the next message part

    logger.info("Finished processing DAT file content.")


# --- S3 Key/Path Functions (_is_valid_s3_key_for_processing, _determine_output_paths - Unchanged) ---

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
    if not s3_object_key.lower().endswith(DAT_FILE_EXTENSION):
        logger.info(f"Skipping non-{DAT_FILE_EXTENSION} file: {s3_object_key}")
        return False
    return True

def _determine_output_paths(s3_object_key: str) -> tuple[str, str, str]:
    """
    Determines the base output path, extracted username, and output key template for S3.
    Returns (base_output_path, extracted_username, output_key_template).
    Raises ValueError if the key format is unexpected.
    """
    s3_key_components = s3_object_key.split('/')
    if len(s3_key_components) < 3:
         raise ValueError(f"Cannot determine output paths from key: {s3_object_key}")

    site_path_components = s3_key_components[:-3]
    extracted_username = s3_key_components[-3]
    base_output_path = '/'.join(site_path_components + [extracted_username])
    original_file_name = os.path.basename(s3_object_key)
    original_file_name_without_ext = original_file_name.rsplit('.', 1)[0]
    split_output_prefix = f"{base_output_path}/{PROCESSED_SUBDIRS[1]}/" # Using "splitdat"
    output_key_template = f"{split_output_prefix}{extracted_username}_{original_file_name_without_ext}_{{}}.{OUTPUT_FILE_EXTENSION}"
    return base_output_path, extracted_username, output_key_template

# --- Lambda Processing Functions (_process_s3_record, lambda_handler - Minor changes) ---

def _process_s3_record(record: dict, context) -> None:
    """
    Processes a single S3 event record. Raises exceptions on failure.
    """
    s3_bucket_name = record['s3']['bucket']['name']
    s3_object_key_encoded = record['s3']['object']['key'] # Get encoded key

    # Decode the S3 object key
    s3_object_key = urllib.parse.unquote_plus(s3_object_key_encoded)
    logger.info(f"Decoded S3 object key: {s3_object_key}")


    logger.info(f"Attempting to process S3 object: s3://{s3_bucket_name}/{s3_object_key}")

    # Use the decoded key for validation
    if not _is_valid_s3_key_for_processing(s3_object_key):
        return

    try:
        # Use the decoded key for path determination
        _, _, output_key_template = _determine_output_paths(s3_object_key)
        logger.info(f"Determined output key template: {output_key_template}")
    except ValueError as e:
        report_error(f"Failed to determine output paths for {s3_object_key}: {e}", context)
        raise

    # Pass the decoded key for content retrieval
    s3_object_content = get_s3_object_content(s3_bucket_name, s3_object_key, context)
    logger.info(f"Retrieved content for {s3_object_key}. Content length: {len(s3_object_content)} bytes.")

    # Process .dat Content - This now handles its own HL7 parsing errors internally
    # but S3 write errors or others will still propagate up.
    process_dat_content(
        s3_bucket_name,
        output_key_template,
        s3_object_content,
        context
    )
    logger.info(f"Successfully processed DAT content for {s3_object_key}.")


def lambda_handler(event, context):
    """
    Main Lambda handler function. Processes S3 event records.
    Requires the `python-hl7` library to be included in the deployment package.
    """
    logger.info("Received event: %s", json.dumps(event))

    if 'Records' not in event:
        logger.warning("Event does not contain 'Records' key. Skipping processing.")
        return {"status": "no records to process"}

    errors = []
    for record in event['Records']:
        try:
            _process_s3_record(record, context)
        except Exception as e:
            # Catch any unhandled exception during the processing of a single record.
            # Use the encoded key from the original record for error reporting if decoding failed or s3_object_key isn't available
            s3_key_for_error = record.get('s3', {}).get('object', {}).get('key', 'Unknown Key')
            error_message = f"CRITICAL FAILURE processing record for {s3_key_for_error}: {e}\n{traceback.format_exc()}"
            report_error(error_message, context)
            errors.append(error_message)
            # If you want S3/Lambda to retry, you MUST re-raise the exception.
            # If you want to process other records, continue (as done here).
            # Consider sending failed records/events to a DLQ.
            # raise e # Uncomment this line to force retries on any error.

    if errors:
        logger.error(f"Processed {len(event['Records'])} records with {len(errors)} failures.")
        return {"status": "dat processing completed with errors"}
    else:
        logger.info(f"All {len(event['Records'])} S3 records processed successfully.")
        return {"status": "dat processing complete"}
