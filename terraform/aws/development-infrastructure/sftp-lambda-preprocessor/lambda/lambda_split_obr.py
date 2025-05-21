
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
HL7_SEGMENT_BREAK_CHARS = ['MSH', 'PID', 'ORC'] # Segments that start a new group or are part of the base

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

def lambda_handler(event, context):
    logger.info("Received event: %s", json.dumps(event))
    s3_client = boto3.client('s3')

    for record in event['Records']:
        s3_bucket_name = record['s3']['bucket']['name']
        s3_object_key = record['s3']['object']['key']

        # Avoid recursive processing of already-processed files
        if any(f"/{subdir}/" in s3_object_key for subdir in PROCESSED_SUBDIRS):
            logger.info(f"Skipping already-processed file: {s3_object_key}")
            continue

        s3_key_components = s3_object_key.split('/')

        # Validate S3 key format: Expects at least `site_path/username/incoming/filename.hl7`
        if len(s3_key_components) < 4:
            logger.warning(f"Unexpected S3 key format (too few components): {s3_object_key}. Skipping.")
            continue

        # Check if the directory before the filename is 'incoming'
        if s3_key_components[-2] != INCOMING_DIR_NAME:
            logger.warning(
                f"S3 key does not have '{INCOMING_DIR_NAME}' as the expected parent directory "
                f"before the filename: {s3_object_key}. Skipping."
            )
            continue

        # Ensure the file is an HL7 file
        if not s3_object_key.endswith(HL7_FILE_EXTENSION):
            logger.info(f"Skipping non-{HL7_FILE_EXTENSION} file: {s3_object_key}")
            continue

        # --- Corrected Logic for Destination Directory ---
        # Assuming S3 key structure: <site_path>/<username>/incoming/<original_file_name>.hl7
        site_path_components = s3_key_components[:-3] # Excludes username, incoming, filename
        extracted_username = s3_key_components[-3] # The component before 'incoming'

        # Reconstruct the base path for the split files, excluding 'incoming'
        base_output_path = '/'.join(site_path_components + [extracted_username])

        original_file_name = os.path.basename(s3_object_key)
        original_file_name_without_ext = original_file_name.rsplit('.', 1)[0]

        # Construct the prefix for split files: <site_path>/<username>/splitobr/
        split_output_prefix = f"{base_output_path}/{PROCESSED_SUBDIRS[2]}/" # Using "splitobr"

        # Template for the output HL7 key
        output_key_template = f"{split_output_prefix}{extracted_username}_{original_file_name_without_ext}_{{}}.{OUTPUT_FILE_EXTENSION}"

        # --- S3 Object Retrieval with Retries ---
        s3_object = None
        for attempt_num in range(3):
            try:
                s3_object = s3_client.get_object(Bucket=s3_bucket_name, Key=s3_object_key)
                break
            except s3_client.exceptions.NoSuchKey:
                logger.warning(f"Attempt {attempt_num+1}: Key not found: {s3_object_key}. Retrying in 1 second.")
                time.sleep(1)
            except Exception as e:
                error_message = f"Error getting S3 object {s3_object_key} on attempt {attempt_num+1}: {e}\n{traceback.format_exc()}"
                report_error(error_message, context)
                raise # Re-raise for other types of errors

        if s3_object is None:
            error_message = f"Failed to retrieve S3 object after 3 attempts: {s3_object_key}"
            report_error(error_message, context)
            raise RuntimeError(error_message)

        # --- Process HL7 Content for OBR splitting ---
        content = s3_object['Body'].read().decode('utf-8')
        segments = content.strip().split('\n')
        base_segments = [] # Holds MSH, PID, ORC segments
        obr_related_segments = [] # Holds OBR and subsequent segments until next MSH/PID/ORC/OBR

        for segment in segments:
            if segment.startswith('OBR'):
                # If we've collected OBR-related segments for a previous OBR, process and reset
                if obr_related_segments:
                    hl7_message = '\n'.join(base_segments + obr_related_segments)
                    output_s3_key = output_key_template.format(uuid.uuid4())
                    logger.info(f"Writing HL7 OBR message to {output_s3_key} in bucket {s3_bucket_name}")
                    try:
                        s3_client.put_object(Bucket=s3_bucket_name, Key=output_s3_key, Body=hl7_message.encode('utf-8'))
                    except Exception as e:
                        error_message = (
                            f"Failed to write HL7 OBR message for segment {segment} to {output_s3_key}. "
                            f"Error: {e}\n{traceback.format_exc()}"
                        )
                        report_error(error_message, context)
                        # Continue processing other segments even if one fails
                    obr_related_segments = [] # Reset for the new OBR group
                obr_related_segments.append(segment) # Add the current OBR segment
            elif any(segment.startswith(prefix) for prefix in HL7_SEGMENT_BREAK_CHARS):
                # If a new MSH, PID, or ORC is encountered, and we have pending OBR segments,
                # this logic assumes these are "base" segments that apply to subsequent OBRs,
                # and previous OBR groups should have been processed.
                # If there are obr_related_segments here, it means we hit a new base segment before a new OBR.
                # This could imply a malformed message or a different structure.
                # For this logic, if we hit a new base segment, any pending OBR group is treated as complete.
                if obr_related_segments:
                    hl7_message = '\n'.join(base_segments + obr_related_segments)
                    output_s3_key = output_key_template.format(uuid.uuid4())
                    logger.info(f"Writing HL7 OBR (pre-base) message to {output_s3_key} in bucket {s3_bucket_name}")
                    try:
                        s3_client.put_object(Bucket=s3_bucket_name, Key=output_s3_key, Body=hl7_message.encode('utf-8'))
                    except Exception as e:
                        error_message = (
                            f"Failed to write HL7 OBR (pre-base) message for segment {segment} to {output_s3_key}. "
                            f"Error: {e}\n{traceback.format_exc()}"
                        )
                        report_error(error_message, context)
                    obr_related_segments = [] # Clear OBR group
                base_segments.append(segment) # Add to base segments
            else:
                # Add any other segments to the current OBR group (e.g., OBX, NTE, etc.)
                obr_related_segments.append(segment)

        # After the loop, process any remaining OBR group
        if obr_related_segments:
            hl7_message = '\n'.join(base_segments + obr_related_segments)
            output_s3_key = output_key_template.format(uuid.uuid4())
            logger.info(f"Writing final HL7 OBR message to {output_s3_key} in bucket {s3_bucket_name}")
            try:
                s3_client.put_object(Bucket=s3_bucket_name, Key=output_s3_key, Body=hl7_message.encode('utf-8'))
            except Exception as e:
                error_message = (
                    f"Failed to write final HL7 OBR message to {output_s3_key}. "
                    f"Error: {e}\n{traceback.format_exc()}"
                )
                report_error(error_message, context) # Just log and move on

    return {"status": "obr processing complete"}
