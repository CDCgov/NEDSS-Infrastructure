
import boto3
import os
# import uuid # UUID is no longer needed for filename generation
import time
import logging
import json
import traceback
import re
import hl7 # Make sure this library is included in your Lambda deployment package
import urllib.parse

from datetime import datetime
from botocore.exceptions import ClientError

# --- Configuration Constants ---
DEFAULT_SPLIT_SUBDIR = "splitdat"
MULTI_OBR_OUTPUT_SUBDIR = "splitdat_multi_obr"
PROCESSED_SUBDIRS = ["splitcsv", DEFAULT_SPLIT_SUBDIR, "splitobr", MULTI_OBR_OUTPUT_SUBDIR] # Added new subdir
INCOMING_DIR_NAME = "incoming"
OUTPUT_FILE_EXTENSION = "hl7"
ERROR_TOPIC_ENV_VAR = 'ERROR_TOPIC_ARN'
DAT_FILE_EXTENSION = '.dat'
HL7_MESSAGE_SEPARATOR = 'MSH'
HL7_FIELD_DELIMITER = '|'
HL7_COMPONENT_DELIMITER = '^'
MAX_S3_RETRIES = 3
S3_RETRY_DELAY_SECONDS = 2

# --- HL7 Field Indices ---
MSH_MESSAGE_CONTROL_ID_IDX = 9
MSH_DATE_TIME_OF_MESSAGE_IDX = 6
PID_PATIENT_IDENTIFIER_LIST_IDX = 2
PID_PATIENT_NAME_IDX = 4
PID_DATE_OF_BIRTH_IDX = 6
PID_RACE_IDX = 10
PID_ETHNIC_GROUP_IDX = 21
PID_LAST_UPDATE_DATE_TIME_IDX = 33

# --- HL7 Validation Sets ---
VALID_RACE_CODES = {"1002-5", "2028-9", "2054-5", "2076-8", "2106-3", "2131-1", "UNK", "REF"}
VALID_RACE_SYSTEMS = {"CDCREC", "HL70005"}
VALID_ETHNIC_CODES = {"2135-2", "2186-5", "UNK", "REF"}
VALID_ETHNIC_SYSTEMS = {"CDCREC", "HL70189"}

# --- Logging Setup ---
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# --- AWS Boto3 Clients ---
s3_client = boto3.client('s3')
sns_client = boto3.client('sns')
cloudwatch_client = boto3.client('cloudwatch')

def report_error(error_msg: str, context) -> None:
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
    s3_object_content = None
    for attempt_num in range(MAX_S3_RETRIES):
        try:
            obj = s3_client.get_object(Bucket=bucket_name, Key=key)
            s3_object_content = obj['Body'].read().decode('utf-8')
            logger.info(f"Successfully retrieved S3 object {key} on attempt {attempt_num+1}.")
            return s3_object_content
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
    sequence_number: int,
    context
) -> None:
    if not hl7_message.strip():
        logger.warning("Skipping write: HL7 message content is empty after processing.")
        return

    output_s3_key = output_key_template.format(sequence_number)
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

def is_valid_hl7_datetime(dt_str: str) -> bool:
    if not dt_str:
        return True
    dt_str_clean = re.sub(r'[+-]\d{4}$', '', dt_str)
    dt_str_clean = dt_str_clean.split('.')[0]
    formats = ["%Y%m%d%H%M%S", "%Y%m%d%H%M", "%Y%m%d%H", "%Y%m%d"]
    for fmt in formats:
        try:
            datetime.strptime(dt_str_clean, fmt)
            return True
        except ValueError:
            continue
    return False

def validate_and_clean_hl7_coded_field(
    raw_field_value: str, valid_codes: set, valid_systems: set, field_label: str, msg_id: str
) -> str:
    if not raw_field_value:
        return ''
    cleaned_field_value = raw_field_value.replace(r"\S" + "\\", HL7_COMPONENT_DELIMITER)
    components = cleaned_field_value.split('~')
    valid_components = []
    for comp in components:
        parts = comp.split(HL7_COMPONENT_DELIMITER)
        if len(parts) < 3:
            logger.warning(f"HL7 Validation Warning (Msg ID: {msg_id}): {field_label} component missing parts: '{comp}'")
            continue
        code, _, system = parts[0].strip(), parts[1].strip(), parts[2].strip()
        if code in valid_codes and system in valid_systems:
            valid_components.append(comp)
        else:
            logger.warning(f"HL7 Validation Warning (Msg ID: {msg_id}): {field_label} component invalid: Code='{code}', System='{system}'")
    if valid_components:
        return '~'.join(valid_components)
    else:
        logger.warning(f"HL7 Validation Warning (Msg ID: {msg_id}): All components in {field_label} are invalid. Clearing field.")
        return ''

def get_field_value(segment: hl7.Segment, index: int) -> str:
    try:
        if index < len(segment):
             return str(segment[index])
        return ''
    except IndexError:
        return ''

def set_field_value(segment: hl7.Segment, index: int, value: str):
    while len(segment) <= index:
        segment.append('')
    segment[index] = value

def clean_hl7_message(msg: hl7.Message, msg_id: str) -> hl7.Message:
    try:
        msh = msg.segment('MSH')
        msh_7_value = get_field_value(msh, MSH_DATE_TIME_OF_MESSAGE_IDX)
        if msh_7_value and not is_valid_hl7_datetime(msh_7_value):
            logger.warning(f"HL7 Validation Warning (Msg ID: {msg_id}): MSH-7 malformed: '{msh_7_value}'.")
    except KeyError:
        logger.warning(f"[{msg_id}]: MSH segment not found for cleaning.")

    try:
        pid = msg.segment('PID')
        pid_33_value = get_field_value(pid, PID_LAST_UPDATE_DATE_TIME_IDX)
        if pid_33_value and not is_valid_hl7_datetime(pid_33_value):
            logger.warning(f"HL7 Validation Warning (Msg ID: {msg_id}): PID-33 invalid: '{pid_33_value}'. Clearing.")
            set_field_value(pid, PID_LAST_UPDATE_DATE_TIME_IDX, '')
        if not get_field_value(pid, PID_PATIENT_IDENTIFIER_LIST_IDX):
             logger.warning(f"HL7 Validation Warning (Msg ID: {msg_id}): PID-3 is empty.")
        if not get_field_value(pid, PID_PATIENT_NAME_IDX):
             logger.warning(f"HL7 Validation Warning (Msg ID: {msg_id}): PID-5 is empty.")
        pid_7_value = get_field_value(pid, PID_DATE_OF_BIRTH_IDX)
        if pid_7_value and not is_valid_hl7_datetime(pid_7_value):
             logger.warning(f"HL7 Validation Warning (Msg ID: {msg_id}): PID-7 malformed: '{pid_7_value}'.")

        raw_pid_10 = get_field_value(pid, PID_RACE_IDX)
        if raw_pid_10:
            cleaned_pid_10 = validate_and_clean_hl7_coded_field(raw_pid_10, VALID_RACE_CODES, VALID_RACE_SYSTEMS, "PID-10 (Race)", msg_id)
            set_field_value(pid, PID_RACE_IDX, cleaned_pid_10)
        raw_pid_22 = get_field_value(pid, PID_ETHNIC_GROUP_IDX)
        if raw_pid_22:
            cleaned_pid_22 = validate_and_clean_hl7_coded_field(raw_pid_22, VALID_ETHNIC_CODES, VALID_ETHNIC_SYSTEMS, "PID-22 (Ethnic Group)", msg_id)
            set_field_value(pid, PID_ETHNIC_GROUP_IDX, cleaned_pid_22)
    except KeyError:
        logger.warning(f"[{msg_id}]: PID segment not found for cleaning.")
    return msg

def process_dat_content(
    s3_bucket_name: str,
    output_key_template_single_obr: str,
    output_key_template_multi_obr: str,
    content: str,
    context
) -> None:
    logger.info("Starting to process DAT file content with HL7 library.")
    raw_message_parts = content.split(HL7_MESSAGE_SEPARATOR)
    message_write_sequence = 0

    for i, msg_body_part in enumerate(raw_message_parts):
        if i == 0 and not msg_body_part.strip():
            logger.debug("Skipping empty part before first MSH.")
            continue
        if not msg_body_part.strip():
            logger.info(f"Skipping empty message part at index {i} (after MSH split).")
            continue

        hl7_message_str = HL7_MESSAGE_SEPARATOR + msg_body_part.strip()
        hl7_message_str = hl7_message_str.replace('\r\n', '\r').replace('\n', '\r')
        logger.debug(f"Processing raw HL7 message part starting with: '{hl7_message_str[:100]}...'")

        try:
            parsed_message = hl7.parse(hl7_message_str)
            try:
                 message_id_for_log = str(parsed_message.segment('MSH')[MSH_MESSAGE_CONTROL_ID_IDX]) or f"Part_{i}"
            except (KeyError, IndexError):
                 message_id_for_log = f"Part_{i}_(MSHErr)"
            logger.info(f"Successfully parsed. Cleaning HL7 message with ID: {message_id_for_log}")

            cleaned_message = clean_hl7_message(parsed_message, message_id_for_log)
            final_hl7_message = str(cleaned_message).replace('\r', '\n')

            if not final_hl7_message.strip():
                logger.warning(f"[{message_id_for_log}]: Message became empty after cleaning. Skipping write.")
                continue

            # OBR Counting Logic
            obr_segments = parsed_message.segments('OBR')
            obr_count = len(obr_segments)
            logger.info(f"Message ID {message_id_for_log} contains {obr_count} OBR segments.")

            selected_output_key_template = output_key_template_single_obr
            if obr_count > 1:
                selected_output_key_template = output_key_template_multi_obr
                logger.info(f"Using multi-OBR S3 key template (subdir: {MULTI_OBR_OUTPUT_SUBDIR}) for Message ID {message_id_for_log}.")
            else:
                logger.info(f"Using single-OBR S3 key template (subdir: {DEFAULT_SPLIT_SUBDIR}) for Message ID {message_id_for_log}.")

            logger.debug(f"[{message_id_for_log}]: Final cleaned HL7 message (first 200 chars): '{final_hl7_message[:200]}...'")
            
            message_write_sequence += 1
            write_hl7_message_to_s3(
                s3_bucket_name,
                selected_output_key_template,
                final_hl7_message,
                message_write_sequence,
                context
            )

        except hl7.exceptions.HL7Exception as e:
            error_message = (
                f"HL7 Parsing FAILED for message part starting with MSH then: '{msg_body_part[:100]}...'. Error: {e}\n"
                f"{traceback.format_exc()}"
            )
            report_error(error_message, context)
            logger.error(f"Skipping message part due to parsing error (see details above).")
            continue
        except Exception as e:
            error_message = (
                f"Generic FAILED for message part starting with MSH then: '{msg_body_part[:100]}...'. Error: {e}\n"
                f"{traceback.format_exc()}"
            )
            report_error(error_message, context)
            logger.error(f"Skipping message part due to generic error (see details above).")
            continue

    logger.info(f"Finished processing DAT file content. {message_write_sequence} messages written.")

def _is_valid_s3_key_for_processing(s3_object_key: str) -> bool:
    if any(f"/{subdir}/" in s3_object_key for subdir in PROCESSED_SUBDIRS):
        logger.info(f"Skipping already-processed file (found in PROCESSED_SUBDIRS): {s3_object_key}")
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
    return True

def _determine_output_paths(s3_object_key: str) -> tuple[str, str, str, str]:
    s3_key_components = s3_object_key.split('/')
    if len(s3_key_components) < 3:
         raise ValueError(f"Cannot determine output paths from key (too few components): {s3_object_key}")

    site_path_components = s3_key_components[:-3]
    extracted_username = s3_key_components[-3]
    base_user_path = '/'.join(site_path_components + [extracted_username])
    original_file_name = os.path.basename(s3_object_key)
    original_file_name_without_ext = original_file_name.rsplit('.', 1)[0]
    
    # Path for standard (single OBR or no OBR) messages
    split_output_prefix_single_obr = f"{base_user_path}/{DEFAULT_SPLIT_SUBDIR}/"
    output_key_template_single_obr = f"{split_output_prefix_single_obr}{extracted_username}_{original_file_name_without_ext}_{{}}.{OUTPUT_FILE_EXTENSION}"
    
    # Path for multi-OBR messages
    split_output_prefix_multi_obr = f"{base_user_path}/{MULTI_OBR_OUTPUT_SUBDIR}/"
    output_key_template_multi_obr = f"{split_output_prefix_multi_obr}{extracted_username}_{original_file_name_without_ext}_multiOBR_{{}}.{OUTPUT_FILE_EXTENSION}"
    
    return base_user_path, extracted_username, output_key_template_single_obr, output_key_template_multi_obr

def _process_s3_record(record: dict, context) -> None:
    s3_bucket_name = record['s3']['bucket']['name']
    s3_object_key_encoded = record['s3']['object']['key']
    s3_object_key = urllib.parse.unquote_plus(s3_object_key_encoded)
    logger.info(f"Decoded S3 object key: {s3_object_key}")
    logger.info(f"Attempting to process S3 object: s3://{s3_bucket_name}/{s3_object_key}")

    if not _is_valid_s3_key_for_processing(s3_object_key):
        return

    try:
        _, _, output_key_template_single_obr, output_key_template_multi_obr = _determine_output_paths(s3_object_key)
        logger.info(f"Determined single-OBR output key template (prefix): {os.path.dirname(output_key_template_single_obr)}/")
        logger.info(f"Determined multi-OBR output key template (prefix): {os.path.dirname(output_key_template_multi_obr)}/")
    except ValueError as e:
        report_error(f"Failed to determine output paths for {s3_object_key}: {e}", context)
        raise

    s3_object_content = get_s3_object_content(s3_bucket_name, s3_object_key, context)
    logger.info(f"Retrieved content for {s3_object_key}. Content length: {len(s3_object_content)} bytes.")

    process_dat_content(
        s3_bucket_name,
        output_key_template_single_obr,
        output_key_template_multi_obr,
        s3_object_content,
        context
    )
    logger.info(f"Successfully processed DAT content for {s3_object_key}.")

def lambda_handler(event, context):
    logger.info("Received event: %s", json.dumps(event))
    if 'Records' not in event:
        logger.warning("Event does not contain 'Records' key. Skipping processing.")
        return {"status": "no records to process"}

    errors = []
    for record in event['Records']:
        try:
            _process_s3_record(record, context)
        except Exception as e:
            s3_key_for_error = record.get('s3', {}).get('object', {}).get('key', 'Unknown Key')
            try:
                s3_key_for_error = urllib.parse.unquote_plus(s3_key_for_error)
            except Exception:
                pass
            
            error_message = f"CRITICAL FAILURE processing S3 record for '{s3_key_for_error}': {e}\n{traceback.format_exc()}"
            report_error(error_message, context)
            errors.append(error_message)
            # raise # Uncomment if a single record failure should trigger S3 event retry.

    if errors:
        logger.error(f"Processed {len(event['Records'])} records with {len(errors)} failures.")
        return {"status": "dat processing completed with errors"}
    else:
        logger.info(f"All {len(event['Records'])} S3 records processed successfully.")
        return {"status": "dat processing complete"}
