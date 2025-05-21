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
# For .dat files, the splitting logic re-adds MSH if it's the start of a new message
ERROR_TOPIC_ENV_VAR = 'ERROR_TOPIC_ARN'
DAT_FILE_EXTENSION = '.dat'
HL7_MESSAGE_SEPARATOR = 'MSH' # Used to split messages within a .dat file

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

        # Validate S3 key format: Expects at least `site_path/username/incoming/filename.dat`
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

        # Ensure the file is a .dat file
        if not s3_object_key.endswith(DAT_FILE_EXTENSION):
            logger.info(f"Skipping non-{DAT_FILE_EXTENSION} file: {s3_object_key}")
            continue

        # --- Corrected Logic for Destination Directory ---
        # Assuming S3 key structure: <site_path>/<username>/incoming/<original_file_name>.dat
        site_path_components = s3_key_components[:-3] # Excludes username, incoming, filename
        extracted_username = s3_key_components[-3] # The component before 'incoming'

        # Reconstruct the base path for the split files, excluding 'incoming'
        base_output_path = '/'.join(site_path_components + [extracted_username])

        original_file_name = os.path.basename(s3_object_key)
        original_file_name_without_ext = original_file_name.rsplit('.', 1)[0]

        # Construct the prefix for split files: <site_path>/<username>/splitdat/
        split_output_prefix = f"{base_output_path}/{PROCESSED_SUBDIRS[1]}/" # Using "splitdat"

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

        # --- Process .dat Content ---
        content = s3_object['Body'].read().decode('utf-8')
        # Split by 'MSH' to separate HL7 messages that might be concatenated
        messages = content.strip().split(HL7_MESSAGE_SEPARATOR)

        for i, msg_part in enumerate(messages):
            if msg_part.strip():
                # Re-add 'MSH' to the beginning of each message part,
                # unless it's the very first part (which might be empty if the file starts with MSH)
                final_hl7_message = HL7_MESSAGE_SEPARATOR + msg_part if i > 0 else msg_part.strip()
                if not final_hl7_message: # Skip if it's an empty string after stripping
                    continue

                output_s3_key = output_key_template.format(uuid.uuid4())
                logger.info(f"Writing HL7 from DAT to {output_s3_key} in bucket {s3_bucket_name}")

                try:
                    s3_client.put_object(Bucket=s3_bucket_name, Key=output_s3_key, Body=final_hl7_message.encode('utf-8'))
                except Exception as e:
                    error_message = (
                        f"Failed to write HL7 message for part to {output_s3_key}. "
                        f"Error: {e}\n{traceback.format_exc()}"
                    )
                    report_error(error_message, context)
                    continue

    return {"status": "dat processing complete"}
