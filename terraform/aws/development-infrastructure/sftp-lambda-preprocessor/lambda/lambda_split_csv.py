
import boto3
import os
import uuid
import time
import logging
import json
import traceback

# --- Configuration Constants ---
# These can be made environment variables or loaded from a config file for production
PROCESSED_SUBDIRS = ["splitcsv", "splitdat", "splitobr"]
INCOMING_DIR_NAME = "incoming"
OUTPUT_FILE_EXTENSION = "hl7"
HL7_MESSAGE_PREFIX = "MSH|^~\\&|CSVAPP|||"
ERROR_TOPIC_ENV_VAR = 'ERROR_TOPIC_ARN'

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

        # Validate S3 key format: Expects at least `site_path/username/incoming/filename.csv`
        # This means at least 4 components are needed: site_path, username, incoming, filename
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

        # Ensure the file is a CSV
        if not s3_object_key.endswith('.csv'):
            logger.info(f"Skipping non-.csv file: {s3_object_key}")
            continue

        # --- Corrected Logic for Destination Directory ---
        # Assuming S3 key structure: <site_path>/<username>/incoming/<original_file_name>.csv
        # Example: my_site/my_user/incoming/data.csv

        # site_path_components will be everything before 'username'
        site_path_components = s3_key_components[:-3] # Excludes username, incoming, filename

        # Extract username (the component before 'incoming')
        extracted_username = s3_key_components[-3]

        # Reconstruct the base path for the split files, excluding 'incoming'
        base_output_path = '/'.join(site_path_components + [extracted_username])

        original_file_name = os.path.basename(s3_object_key)
        # Remove .csv extension for the output file naming
        original_file_name_without_ext = original_file_name.rsplit('.', 1)[0]

        # Construct the prefix for split files: <site_path>/<username>/splitcsv/
        split_output_prefix = f"{base_output_path}/{PROCESSED_SUBDIRS[0]}/" # Using "splitcsv" from PROCESSED_SUBDIRS

        # Template for the output HL7 key
        # Example: my_site/my_user/splitcsv/my_user_data_{uuid}.hl7
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
                # For other errors, we might want to exit immediately or retry based on error type
                raise # Re-raise if it's not NoSuchKey, or a more specific retry logic

        if s3_object is None:
            error_message = f"Failed to retrieve S3 object after 3 attempts: {s3_object_key}"
            report_error(error_message, context)
            raise RuntimeError(error_message) # Raise a runtime error to stop execution

        # --- Process CSV Content ---
        content = s3_object['Body'].read().decode('utf-8')
        lines = content.strip().split('\n')

        for line in lines:
            if line.strip(): # Process non-empty lines
                hl7_message = f'{HL7_MESSAGE_PREFIX}{line}'
                # Generate a unique key for each HL7 message
                output_s3_key = output_key_template.format(uuid.uuid4())
                logger.info(f"Writing HL7 to {output_s3_key} in bucket {s3_bucket_name}")

                try:
                    s3_client.put_object(Bucket=s3_bucket_name, Key=output_s3_key, Body=hl7_message.encode('utf-8'))
                except Exception as e:
                    error_message = (
                        f"Failed to write HL7 message for line to {output_s3_key}. "
                        f"Error: {e}\n{traceback.format_exc()}"
                    )
                    report_error(error_message, context)
                    # Depending on requirements, you might continue to process other lines or stop
                    # For now, we'll log and continue for other lines in the same CSV
                    continue # Continue to the next line in the CSV if put_object fails

    return {"status": "csv processing complete"}
