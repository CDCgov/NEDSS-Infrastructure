
import boto3
import os
import uuid
import time
import logging
import json
import traceback
import urllib.parse

# --- Configuration Constants ---
PROCESSED_SUBDIRS = ["splitcsv", "splitdat", "splitobr"]
INCOMING_DIR_NAME = "incoming" # Or other directories this Lambda might process from
# PROCESSED_SUBDIRS[1] is 'splitdat'
# PROCESSED_SUBDIRS[2] is 'splitobr'
OUTPUT_FILE_EXTENSION = "hl7"
ERROR_TOPIC_ENV_VAR = 'ERROR_TOPIC_ARN'
HL7_FILE_EXTENSION = '.hl7' # Assuming inputs will be .hl7 files
HL7_BASE_SEGMENTS_PREFIXES = ['MSH', 'PID', 'ORC'] # Segments that start a new message or apply globally

# --- Logging Setup ---
logger = logging.getLogger()
#logger.setLevel(logging.INFO) # Set to INFO for production. Use DEBUG for development.
logger.setLevel(logging.DEBUG) # Set to INFO for production. Use DEBUG for development.

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
    for attempt_num in range(3): # Max 3 retries
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
            raise

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
    if not hl7_message_parts: # Check if parts list is empty
        logger.warning("Skipping write: hl7_message_parts is empty.")
        return

    # Ensure there is at least one OBR segment in the parts being written
    if not any(part.startswith('OBR') for part in hl7_message_parts):
        logger.info("Skipping write: No OBR segment found in the current message group to be written.")
        return

    hl7_message = '\n'.join(hl7_message_parts) # Using \n for consistency in output files
    output_s3_key = output_key_template.format(uuid.uuid4())
    
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
        raise

def process_hl7_segments_for_obr(
    s3_client: boto3.client,
    s3_bucket_name: str,
    output_key_template: str,
    content: str,
    context
) -> None:
    """
    Splits HL7 content by OBR segments and writes each resulting message to S3.
    Handles various segment terminator types (\r, \n, \r\n).
    """
    # Normalize line endings to \n, then split into segments.
    # Filter out any segments that are empty after stripping (e.g., from multiple newlines).
    normalized_content = content.replace('\r\n', '\n').replace('\r', '\n')
    segments = [s for s in normalized_content.strip().split('\n') if s.strip()]

    current_base_segments = []
    current_obr_group_segments = []
    obr_active_in_group = False

    logger.debug(f"Starting HL7 segment processing for OBR splitting. Number of segments found: {len(segments)} for key template prefix: {output_key_template.rsplit('_obr_',1)[0]}")
    if not segments:
        logger.info("No segments found in the content after normalization and stripping.")
        return

    for i, segment_stripped in enumerate(segments):
        # segment_stripped is already effectively stripped due to the list comprehension's `if s.strip()`
        segment_prefix = segment_stripped[:3]
        # Be cautious logging full segment_stripped if PHI is a concern at DEBUG level.
        logger.debug(f"Processing segment {i+1}/{len(segments)}: Prefix='{segment_prefix}'.")

        if segment_prefix == 'MSH':
            # If an OBR group was active, write it out before resetting for the new MSH.
            if obr_active_in_group and current_base_segments:
                logger.info("MSH encountered. Flushing previous OBR group (if active and valid).")
                write_hl7_message_to_s3(
                    s3_client,
                    s3_bucket_name,
                    output_key_template,
                    current_base_segments + current_obr_group_segments,
                    context
                )
            # Reset for the new message context defined by this MSH
            current_base_segments = [segment_stripped]
            current_obr_group_segments = []
            obr_active_in_group = False
            logger.debug("MSH processed. Base segments reset and current MSH added.")

        elif segment_prefix == 'OBR':
            # If a previous OBR group was active, write it out.
            if obr_active_in_group and current_base_segments:
                logger.info("New OBR encountered. Flushing previous OBR group (if active and valid).")
                write_hl7_message_to_s3(
                    s3_client,
                    s3_bucket_name,
                    output_key_template,
                    current_base_segments + current_obr_group_segments,
                    context
                )
            # Start a new OBR group with the current OBR segment.
            # It's only valid if we have base segments (i.e., an MSH has been seen).
            if current_base_segments:
                current_obr_group_segments = [segment_stripped]
                obr_active_in_group = True
                logger.debug("OBR processed. New OBR group started.")
            else:
                logger.warning(f"OBR segment found but no MSH context (current_base_segments is empty). Discarding OBR: {segment_stripped[:50]}...")


        elif segment_prefix in HL7_BASE_SEGMENTS_PREFIXES and segment_prefix != 'MSH': # e.g., PID, ORC
            # Add to base segments only if an MSH has established a message context.
            if current_base_segments:
                current_base_segments.append(segment_stripped)
                logger.debug(f"{segment_prefix} added to base_segments.")
            else:
                logger.warning(f"Segment '{segment_prefix}' found before MSH context established. Discarding: {segment_stripped[:50]}...")

        else: # OBX, NTE, or other segments
            # Add to the current OBR group only if an OBR is active and MSH context exists.
            if obr_active_in_group and current_base_segments:
                current_obr_group_segments.append(segment_stripped)
                logger.debug(f"Segment '{segment_prefix}' added to current OBR group.")
            else:
                if not current_base_segments:
                     logger.warning(f"Segment '{segment_prefix}' found before MSH context. Discarding for OBR splitting: {segment_stripped[:50]}...")
                elif not obr_active_in_group:
                     logger.debug(f"Segment '{segment_prefix}' found but no OBR is active. Discarding from OBR group: {segment_stripped[:50]}...")

    # After the loop, write any remaining OBR group if it's active and valid.
    if obr_active_in_group and current_base_segments:
        logger.info("End of segments. Flushing final OBR group (if active and valid).")
        write_hl7_message_to_s3(
            s3_client,
            s3_bucket_name,
            output_key_template,
            current_base_segments + current_obr_group_segments,
            context
        )
    else:
        logger.info(f"No active and valid OBR group to flush at the end of the file. OBR active: {obr_active_in_group}, Base segments present: {bool(current_base_segments)}")


def lambda_handler(event, context):
    logger.info("Received event: %s", json.dumps(event))
    s3_client = boto3.client('s3')

    allowed_source_parent_dirs = {INCOMING_DIR_NAME, PROCESSED_SUBDIRS[1]} # "incoming", "splitdat"

    for record in event['Records']:
        s3_bucket_name = record['s3']['bucket']['name']
        s3_object_key_encoded = record['s3']['object']['key']

        s3_object_key = urllib.parse.unquote_plus(s3_object_key_encoded)
        logger.info(f"Decoded S3 object key: {s3_object_key}")

        final_obr_output_dir_segment = f"/{PROCESSED_SUBDIRS[2]}/" # e.g. "/splitobr/"
        if final_obr_output_dir_segment in s3_object_key:
            logger.info(f"Skipping file already in the final OBR output directory '{final_obr_output_dir_segment}': {s3_object_key}")
            continue

        s3_key_components = s3_object_key.split('/')
        if len(s3_key_components) < 4:
            logger.warning(f"Unexpected S3 key format (too few components): {s3_object_key}. Skipping.")
            continue

        parent_dir_of_file = s3_key_components[-2]
        if parent_dir_of_file not in allowed_source_parent_dirs:
            logger.warning(
                f"S3 key's parent directory '{parent_dir_of_file}' is not in the allowed set "
                f"{allowed_source_parent_dirs} for OBR splitting: {s3_object_key}. Skipping."
            )
            continue
        
        if not s3_object_key.lower().endswith(HL7_FILE_EXTENSION):
            logger.info(f"Skipping non-{HL7_FILE_EXTENSION} file: {s3_object_key}")
            continue

        logger.info(f"File {s3_object_key} passed pre-checks for OBR splitting.")

        try:
            site_path_components = s3_key_components[:-3]
            extracted_username = s3_key_components[-3]
            base_output_path = '/'.join(site_path_components + [extracted_username])
            original_file_name = os.path.basename(s3_object_key)
            original_file_name_without_ext = original_file_name.rsplit('.', 1)[0]
            
            split_output_prefix = f"{base_output_path}/{PROCESSED_SUBDIRS[2]}/" # Output to "splitobr"
            output_key_template = f"{split_output_prefix}{extracted_username}_{original_file_name_without_ext}_obr_{{}}.{OUTPUT_FILE_EXTENSION}"
            logger.info(f"Output key template for OBR split files: {output_key_template}")

        except IndexError:
            report_error(f"Could not determine output paths due to unexpected S3 key structure: {s3_object_key}", context)
            continue

        try:
            s3_object_content = get_s3_object_content(s3_client, s3_bucket_name, s3_object_key, context)
        except RuntimeError:
            continue 

        try:
            process_hl7_segments_for_obr(
                s3_client,
                s3_bucket_name,
                output_key_template,
                s3_object_content,
                context
            )
            logger.info(f"Successfully completed OBR splitting process for {s3_object_key}")
        except Exception as e:
            error_message = f"Failed during HL7 content processing for OBR splitting in {s3_object_key}: {e}\n{traceback.format_exc()}"
            report_error(error_message, context)
            continue

    return {"status": "obr processing complete"}
