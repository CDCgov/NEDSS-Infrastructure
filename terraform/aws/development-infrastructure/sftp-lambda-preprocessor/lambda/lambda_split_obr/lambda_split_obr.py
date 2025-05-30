
import boto3
import os
import uuid
import time
import logging
import json
import traceback
import urllib.parse # Add this import

# --- Configuration Constants ---
PROCESSED_SUBDIRS = ["splitcsv", "splitdat", "splitobr"]
INCOMING_DIR_NAME = "incoming"
OUTPUT_FILE_EXTENSION = "hl7"
ERROR_TOPIC_ENV_VAR = 'ERROR_TOPIC_ARN'
HL7_FILE_EXTENSION = '.hl7'
HL7_BASE_SEGMENTS_PREFIXES = ['MSH', 'PID', 'ORC'] # Segments that start a new message or apply globally

# --- Logging Setup ---
logger = logging.getLogger()
logger.setLevel(logging.INFO) # Set to INFO for production. Use DEBUG only in secure, isolated dev environments.

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
            obj = s3_client.get_object(Bucket=bucket_name, Key=key) # key will be decoded
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
    hl7_message_parts: list,
    context
) -> None:
    """
    Constructs an HL7 message from parts and writes it to S3.
    Includes a check to ensure an OBR segment is present before writing.
    """
    # Ensure there is at least one OBR segment in the parts being written
    if not any(part.startswith('OBR') for part in hl7_message_parts):
        logger.info("Skipping write: No OBR segment found in the current message group.")
        return

    hl7_message = '\n'.join(hl7_message_parts)
    output_s3_key = output_key_template.format(uuid.uuid4())
    
    # IMPORTANT: Do NOT log hl7_message content here due to PHI.
    logger.info(f"Attempting to write HL7 OBR message to S3. Key: {output_s3_key}, Bucket: {s3_bucket_name}.")

    try:
        s3_client.put_object(Bucket=s3_bucket_name, Key=output_s3_key, Body=hl7_message.encode('utf-8'))
        logger.info(f"Successfully wrote HL7 OBR message to {output_s3_key}")
    except Exception as e:
        error_message = (
            f"CRITICAL ERROR: Failed to write HL7 message to {output_s3_key}. "
            f"Error: {e}\n{traceback.format_exc()}"
        )
        report_error(error_message, context)
        raise # Re-raise the exception to indicate failure

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
    current_base_segments = []
    current_obr_group_segments = []
    obr_active_in_group = False # Flag to indicate if an OBR is being accumulated in the current group

    logger.debug("Starting HL7 segment processing.") # Debug level, won't show by default

    for i, segment in enumerate(segments):
        segment_stripped = segment.strip()
        if not segment_stripped:
            logger.debug(f"Skipping empty segment at line {i+1}.")
            continue

        segment_prefix = segment_stripped[:3]
        # IMPORTANT: Do NOT log segment_stripped content here due to PHI.
        logger.debug(f"Processing segment {i+1}: {segment_prefix}.")
        logger.debug(f"Current state: base={len(current_base_segments)}, obr_group={len(current_obr_group_segments)}, obr_active={obr_active_in_group}")

        if segment_prefix == 'MSH':
            # MSH signals a new message context.
            # If there's an active OBR group from the previous context, write it now.
            if obr_active_in_group:
                logger.info(f"MSH encountered. Flushing previous OBR group (if active).")
                write_hl7_message_to_s3(
                    s3_client,
                    s3_bucket_name,
                    output_key_template,
                    current_base_segments + current_obr_group_segments,
                    context
                )
            # Reset for the new message context
            current_base_segments = [segment_stripped]
            current_obr_group_segments = []
            obr_active_in_group = False # No OBR yet in this new group
            logger.debug(f"MSH processed. New base count: {len(current_base_segments)}, obr_group reset.")

        elif segment_prefix == 'OBR':
            # A new OBR means the previous OBR group is complete.
            # If there was an OBR active in the previous group, write it out.
            if obr_active_in_group:
                logger.info(f"OBR encountered. Flushing previous OBR group (if active).")
                write_hl7_message_to_s3(
                    s3_client,
                    s3_bucket_name,
                    output_key_template,
                    current_base_segments + current_obr_group_segments,
                    context
                )
            # Start a new OBR group with the current OBR segment
            current_obr_group_segments = [segment_stripped]
            obr_active_in_group = True # An OBR is now active in this group
            logger.debug(f"OBR processed. New obr_group count: {len(current_obr_group_segments)}, obr_active=True.")

        elif segment_prefix in ['PID', 'ORC']:
            # These are base segments for the current message context, add to base.
            current_base_segments.append(segment_stripped)
            logger.debug(f"{segment_prefix} added to base_segments. Base count: {len(current_base_segments)}.")

        else: # Any other segment (OBX, NTE, SFT, etc.)
            # These segments belong to the current OBR group ONLY if an OBR is active.
            # This prevents segments like SFT from creating "phantom" OBR groups.
            if obr_active_in_group:
                current_obr_group_segments.append(segment_stripped)
                logger.debug(f"Other segment '{segment_prefix}' added to obr_group. OBR group count: {len(current_obr_group_segments)}.")
            else:
                logger.debug(f"Discarding segment '{segment_prefix}' as no OBR is active in group and it's not a base segment.")
                # Segments encountered here before an OBR are effectively discarded for this splitting logic.
                # You could add more specific handling or logging here if these need to be captured.

    # After the loop, write any remaining OBR group (the last one in the file)
    logger.debug("End of segments. Checking for final OBR group to flush.")
    if obr_active_in_group:
        logger.info("Flushing final OBR group.")
        write_hl7_message_to_s3(
            s3_client,
            s3_bucket_name,
            output_key_template,
            current_base_segments + current_obr_group_segments,
            context
        )
    else:
        logger.info("No active OBR group to flush at the end of the file.")


def lambda_handler(event, context):
    logger.info("Received event: %s", json.dumps(event))
    s3_client = boto3.client('s3')

    for record in event['Records']:
        s3_bucket_name = record['s3']['bucket']['name']
        s3_object_key_encoded = record['s3']['object']['key'] # Get encoded key

        # Decode the S3 object key
        s3_object_key = urllib.parse.unquote_plus(s3_object_key_encoded)
        logger.info(f"Decoded S3 object key: {s3_object_key}")


        # Pre-checks for key format and file type (use decoded key)
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

        # --- Determine Output Paths --- (use decoded key)
        site_path_components = s3_key_components[:-3]
        extracted_username = s3_key_components[-3]
        base_output_path = '/'.join(site_path_components + [extracted_username])
        original_file_name = os.path.basename(s3_object_key)
        original_file_name_without_ext = original_file_name.rsplit('.', 1)[0]
        split_output_prefix = f"{base_output_path}/{PROCESSED_SUBDIRS[2]}/" # Using "splitobr"
        output_key_template = f"{split_output_prefix}{extracted_username}_{original_file_name_without_ext}_{{}}.{OUTPUT_FILE_EXTENSION}"

        # --- S3 Object Retrieval --- (pass decoded key)
        try:
            s3_object_content = get_s3_object_content(s3_client, s3_bucket_name, s3_object_key, context)
        except RuntimeError:
            # get_s3_object_content already reported the error
            continue # Move to the next S3 record

        # --- Process HL7 Content for OBR splitting ---
        try:
            process_hl7_segments_for_obr(
                s3_client,
                s3_bucket_name,
                output_key_template,
                s3_object_content,
                context
            )
        except Exception as e:
            error_message = f"Failed to process HL7 content for {s3_object_key}: {e}\n{traceback.format_exc()}"
            report_error(error_message, context)
            # Continue to the next S3 record if processing fails for one
            continue

    return {"status": "obr processing complete"}
