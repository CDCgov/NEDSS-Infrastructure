
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
    hl7_message: str,
    context
) -> None:
    """
    Writes a single HL7 message to S3.
    """
    output_s3_key = output_key_template.format(uuid.uuid4())
    logger.info(f"Writing HL7 from DAT to {output_s3_key} in bucket {s3_bucket_name}")

    try:
        s3_client.put_object(Bucket=s3_bucket_name, Key=output_s3_key, Body=hl7_message.encode('utf-8'))
    except Exception as e:
        error_message = (
            f"Failed to write HL7 message to {output_s3_key}. "
            f"Error: {e}\n{traceback.format_exc()}"
        )
        report_error(error_message, context)
        # Continue processing other messages even if one fails to write

def process_dat_content(
    s3_client: boto3.client,
    s3_bucket_name: str,
    output_key_template: str,
    content: str,
    context
) -> None:
    """
    Splits .dat file content into individual HL7 messages and writes them to S3.
    """
    # Split by 'MSH' to separate HL7 messages that might be concatenated
    messages = content.strip().split(HL7_MESSAGE_SEPARATOR)

    for i, msg_part in enumerate(messages):
        if not msg_part.strip(): # Skip empty parts resulting from split
            continue

        # Re-add 'MSH' to the beginning of each message part,
        # unless it's the very first part (which might be empty if the file starts with MSH)
        final_hl7_message = HL7_MESSAGE_SEPARATOR + msg_part if i > 0 else msg_part.strip()
        
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
        process_dat_content(
            s3_client,
            s3_bucket_name,
            output_key_template,
            s3_object_content,
            context
        )

    return {"status": "dat processing complete"}
