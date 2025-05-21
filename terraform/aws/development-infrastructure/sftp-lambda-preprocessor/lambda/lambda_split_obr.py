
import boto3
import os
import uuid
import time
import logging
import json
import traceback

# --- Configuration Constants ---
PROCESSED_SUBDIRS = ["splitcsv", "splitdat", "splitobr"]
INCOMING_DIR_NAME = "incoming"
OUTPUT_FILE_EXTENSION = "hl7"
ERROR_TOPIC_ENV_VAR = 'ERROR_TOPIC_ARN'
HL7_FILE_EXTENSION = '.hl7'
HL7_BASE_SEGMENTS_PREFIXES = ['MSH', 'PID', 'ORC'] # Segments that start a new message or apply globally

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
    hl7_message_parts: list,
    context
) -> None:
    """
    Constructs an HL7 message from parts and writes it to S3.
    """
    if not hl7_message_parts:
        return # Nothing to write

    hl7_message = '\n'.join(hl7_message_parts)
    output_s3_key = output_key_template.format(uuid.uuid4())
    logger.info(f"Writing HL7 OBR message to {output_s3_key} in bucket {s3_bucket_name}")

    try:
        s3_client.put_object(Bucket=s3_bucket_name, Key=output_s3_key, Body=hl7_message.encode('utf-8'))
    except Exception as e:
        error_message = (
            f"Failed to write HL7 message to {output_s3_key}. "
            f"Error: {e}\n{traceback.format_exc()}"
        )
        report_error(error_message, context)
        # Decision: Continue processing other OBR groups even if one fails to write

# Helper functions to reduce complexity of process_hl7_segments_for_obr
def _process_current_obr_group(
    s3_client: boto3.client,
    s3_bucket_name: str,
    output_key_template: str,
    base_segments: list,
    obr_related_segments: list,
    context
) -> list: # Returns an empty list for obr_related_segments
    """
    Writes the current OBR group (base + obr_related) to S3 and clears obr_related_segments.
    """
    if obr_related_segments:
        write_hl7_message_to_s3(
            s3_client,
            s3_bucket_name,
            output_key_template,
            base_segments + obr_related_segments,
            context
        )
    return [] # Reset obr_related_segments

def process_hl7_segments_for_obr(
    s3_client: boto3.client,
    s3_bucket_name: str,
    output_key_template: str,
    content: str,
    context
) -> None:
    """
    Splits HL7 content by OBR segments and writes each resulting message to S3.
    """
    segments = content.strip().split('\n')
    base_segments = []
    obr_related_segments = []

    for segment in segments:
        segment_stripped = segment.strip()
        if not segment_stripped:
            continue

        if segment_stripped.startswith('OBR'):
            # When an OBR segment is found, finish the previous OBR group if any
            obr_related_segments = _process_current_obr_group(
                s3_client,
                s3_bucket_name,
                output_key_template,
                base_segments,
                obr_related_segments,
                context
            )
            obr_related_segments.append(segment_stripped) # Add the current OBR segment
        elif any(segment_stripped.startswith(prefix) for prefix in HL7_BASE_SEGMENTS_PREFIXES):
            # When a new base segment (MSH, PID, ORC) is found, finish current OBR group
            obr_related_segments = _process_current_obr_group(
                s3_client,
                s3_bucket_name,
                output_key_template,
                base_segments,
                obr_related_segments,
                context
            )
            base_segments.append(segment_stripped) # Add to base segments
        else:
            # Add any other segments to the current OBR group (e.g., OBX, NTE, etc.)
            obr_related_segments.append(segment_stripped)

    # After the loop, process any remaining OBR group
    _process_current_obr_group(
        s3_client,
        s3_bucket_name,
        output_key_template,
        base_segments,
        obr_related_segments,
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
        if not s3_object_key.endswith(HL7_FILE_EXTENSION):
            logger.info(f"Skipping non-{HL7_FILE_EXTENSION} file: {s3_object_key}")
            continue

        # --- Determine Output Paths ---
        site_path_components = s3_key_components[:-3]
        extracted_username = s3_key_components[-3]
        base_output_path = '/'.join(site_path_components + [extracted_username])
        original_file_name = os.path.basename(s3_object_key)
        original_file_name_without_ext = original_file_name.rsplit('.', 1)[0]
        split_output_prefix = f"{base_output_path}/{PROCESSED_SUBDIRS[2]}/" # Using "splitobr"
        output_key_template = f"{split_output_prefix}{extracted_username}_{original_file_name_without_ext}_{{}}.{OUTPUT_FILE_EXTENSION}"

        # --- S3 Object Retrieval ---
        try:
            s3_object_content = get_s3_object_content(s3_client, s3_bucket_name, s3_object_key, context)
        except RuntimeError:
            # get_s3_object_content already reported the error
            continue # Move to the next S3 record

        # --- Process HL7 Content for OBR splitting ---
        process_hl7_segments_for_obr(
            s3_client,
            s3_bucket_name,
            output_key_template,
            s3_object_content,
            context
        )

    return {"status": "obr processing complete"}
