
import boto3
import os
import uuid
import time
import logging
import json
import traceback
import csv # Added for DictReader
import io # Added for StringIO
from datetime import datetime # Added for date formatting

# --- Configuration Constants ---
PROCESSED_SUBDIRS = ["splitcsv", "splitdat", "splitobr"]
INCOMING_DIR_NAME = "incoming"
OUTPUT_FILE_EXTENSION = "hl7"
ERROR_TOPIC_ENV_VAR = 'ERROR_TOPIC_ARN'
CSV_FILE_EXTENSION = '.csv'

# --- Logging Setup ---
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def report_error(error_msg: str, context) -> None:
    """
    Reports an error by logging it and attempting to publish to an SNS topic.
    """
    logger.error(error_msg) # Log the error message
    try:
        sns = boto3.client('sns') # Initialize SNS client
        topic_arn = os.environ.get(ERROR_TOPIC_ENV_VAR) # Get SNS topic ARN from environment
        if topic_arn:
            sns.publish( # Publish message to SNS topic
                TopicArn=topic_arn,
                Subject=f"Lambda Error in {context.function_name}",
                Message=error_msg
            )
    except Exception as sns_error:
        logger.warning("SNS publish failed: %s", str(sns_error)) # Log if SNS publish fails

def escape_hl7(text):
    """
    Escapes characters in text that have special meaning in HL7.
    """
    # Escapes newline, carriage return, and pipe characters
    return str(text).replace("\n", "\\.br\\").replace("\r", "").replace("|", "\\F\\")

def generate_hl7_message_from_csv_row(row: dict, message_id: str) -> str:
    """
    Generates an HL7 ORU^R01 message from a single CSV row.
    This logic is adapted from the provided lambda_function.py.
    """
    try:
        # Format MSH timestamp from 'TestDate'
        msh_timestamp = datetime.strptime(row['TestDate'].strip(), "%m/%d/%Y").strftime("%Y%m%d%H%M")
        # Format DateOfBirth
        dob = datetime.strptime(row['DateOfBirth'].strip(), "%m/%d/%Y").strftime("%Y%m%d")
    except KeyError as e:
        raise ValueError(f"Missing expected date field in CSV row: {e}")
    except ValueError as e:
        raise ValueError(f"Invalid date format in CSV row: {e}")

    accession_raw = row.get('AccessionNumber', '').strip() # Get AccessionNumber, strip whitespace
    if not accession_raw:
        raise ValueError(f"Missing AccessionNumber in row for message {message_id}") # Raise error if missing
    accession = escape_hl7(accession_raw) # Escape HL7 special characters

    try:
        resulted_test_id = row['ResultedTestID'] # Get ResultedTestID
        resulted_test_name = escape_hl7(row['ResultedTestName']) # Get and escape ResultedTestName
        patient_id = row['Patient_ID'] # Get Patient_ID
        pt_last_name = escape_hl7(row['PtLastName']) # Get and escape PtLastName
        pt_first_name = escape_hl7(row['PtFirstName']) # Get and escape PtFirstName
        sex = row['Sex'] # Get Sex
        sending_facility = escape_hl7(row['SendingFacility']) # Get and escape SendingFacility
        test_result = escape_hl7(row['TestResult']) # Get and escape TestResult
    except KeyError as e:
        raise ValueError(f"Missing expected CSV column in row for message {message_id}: {e}")

    obr4 = f"{resulted_test_id}^{resulted_test_name}" # Construct OBR-4 field

    return "\n".join([ # Join HL7 segments with newline
        f"MSH|^~\\&|SFTP_APP|{sending_facility}|ELR_RECEIVER|VI_DOH|{msh_timestamp}||ORU^R01|{message_id}|P|2.5.1", # MSH segment
        f"PID|||{patient_id}||{pt_last_name}^{pt_first_name}||{dob}|{sex}", # PID segment
        f"ORC|RE||||||||", # ORC segment
        f"OBR|1|{patient_id}|{accession}|{obr4}|||{msh_timestamp}", # OBR segment
        f"OBX|1|TX|{obr4}||{test_result}||||||F" # OBX segment
    ])

def get_s3_object_content(s3_client: boto3.client, bucket_name: str, key: str, context) -> str:
    """
    Retrieves content from an S3 object with retry logic.
    Raises RuntimeError if object cannot be retrieved after retries.
    """
    s3_object_content = None
    for attempt_num in range(3): # Retry up to 3 times
        try:
            obj = s3_client.get_object(Bucket=bucket_name, Key=key) # Get S3 object
            s3_object_content = obj['Body'].read().decode('utf-8') # Read and decode content
            break # Break loop on success
        except s3_client.exceptions.NoSuchKey:
            logger.warning(f"Attempt {attempt_num+1}: Key not found: {key}. Retrying in 1 second.") # Warn and retry on NoSuchKey
            time.sleep(1) # Wait 1 second before retrying
        except Exception as e:
            error_message = f"Error getting S3 object {key} on attempt {attempt_num+1}: {e}\n{traceback.format_exc()}" # Log other errors
            report_error(error_message, context) # Report error
            raise # Re-raise for other types of errors immediately

    if s3_object_content is None: # If content not retrieved after retries
        error_message = f"Failed to retrieve S3 object after 3 attempts: {key}" # Error message
        report_error(error_message, context) # Report error
        raise RuntimeError(error_message) # Raise runtime error
    
    return s3_object_content # Return content

def process_csv_content_and_upload_hl7(
    s3_client: boto3.client,
    s3_bucket_name: str,
    output_key_template: str,
    csv_content: str,
    key_hash_prefix: str,
    context
) -> int:
    """
    Processes CSV content, generates HL7 messages, and uploads them to S3.
    """
    csv_reader = csv.DictReader(io.StringIO(csv_content)) # Create DictReader
    csv_reader.fieldnames = [name.strip() for name in csv_reader.fieldnames] # Normalize headers

    message_count = 0 # Initialize message count
    for i, row in enumerate(csv_reader): # Iterate through CSV rows
        try:
            # Generate a unique message ID based on Patient_ID, ResultedTestID, and row index
            msg_id = f"{row['Patient_ID']}_{row['ResultedTestID']}_{i}"
            hl7_message = generate_hl7_message_from_csv_row(row, msg_id) # Generate HL7 message
            
            # Construct the output key for the HL7 file
            output_s3_key = output_key_template.format(f"{key_hash_prefix}_{msg_id}")

            logger.info(f"Writing HL7 message for {msg_id} to {output_s3_key}") # Log writing action
            s3_client.put_object( # Put object to S3
                Bucket=s3_bucket_name,
                Key=output_s3_key,
                Body=hl7_message.encode('utf-8')
            )
            message_count += 1 # Increment count
        except ValueError as ve:
            error_msg = f"Data validation error for row {i+1} in CSV: {ve}"
            report_error(error_msg, context)
            logger.error(error_msg)
            # Decide if you want to skip this row or stop processing. For now, skipping.
            continue
        except Exception as e:
            error_msg = f"Failed to process row {i+1} from CSV: {e}\n{traceback.format_exc()}" # Log other errors
            report_error(error_msg, context) # Report error
            # Decide if you want to skip this row or stop processing. For now, skipping.
            continue
            
    return message_count # Return processed message count


def lambda_handler(event, context):
    logger.info("Received event: %s", json.dumps(event)) # Log received event
    s3_client = boto3.client('s3') # Initialize S3 client

    for record in event['Records']: # Iterate through S3 event records
        s3_bucket_name = record['s3']['bucket']['name'] # Get bucket name
        s3_object_key = record['s3']['object']['key'] # Get object key

        # Pre-checks for key format and file type
        if any(f"/{subdir}/" in s3_object_key for subdir in PROCESSED_SUBDIRS): # Avoid recursive processing
            logger.info(f"Skipping already-processed file: {s3_object_key}") # Log skipping
            continue

        s3_key_components = s3_object_key.split('/') # Split key into components
        if len(s3_key_components) < 4: # Validate key length
            logger.warning(f"Unexpected S3 key format (too few components): {s3_object_key}. Skipping.") # Warn and skip
            continue
        if s3_key_components[-2] != INCOMING_DIR_NAME: # Validate 'incoming' directory
            logger.warning(
                f"S3 key does not have '{INCOMING_DIR_NAME}' as the expected parent directory "
                f"before the filename: {s3_object_key}. Skipping."
            )
            continue
        if not s3_object_key.endswith(CSV_FILE_EXTENSION): # Validate file extension
            logger.info(f"Skipping non-{CSV_FILE_EXTENSION} file: {s3_object_key}") # Log skipping
            continue

        # --- Determine Output Paths ---
        # Assuming S3 key structure: <site_path>/<username>/incoming/<original_file_name>.csv
        site_path_components = s3_key_components[:-3] # Excludes username, incoming, filename
        extracted_username = s3_key_components[-3] # The component before 'incoming'
        base_output_path = '/'.join(site_path_components + [extracted_username]) # Reconstruct base path
        original_file_name = os.path.basename(s3_object_key) # Get original file name
        original_file_name_without_ext = original_file_name.rsplit('.', 1)[0] # Remove extension
        split_output_prefix = f"{base_output_path}/{PROCESSED_SUBDIRS[0]}/" # Using "splitcsv"
        # The message ID will be generated dynamically per row within the processing function
        output_key_template = f"{split_output_prefix}{extracted_username}_{original_file_name_without_ext}_{{}}.{OUTPUT_FILE_EXTENSION}"

        # Generate a hash prefix for uniqueness, similar to lambda_function.py
        file_key_hash_prefix = hashlib.md5(s3_object_key.encode()).hexdigest()[:8]

        # --- S3 Object Retrieval ---
        try:
            s3_object_content = get_s3_object_content(s3_client, s3_bucket_name, s3_object_key, context) # Get S3 object content
        except RuntimeError:
            # get_s3_object_content already reported the error and raised.
            # This 'except' block effectively catches the re-raise and allows the loop to continue.
            continue # Move to the next S3 record

        # --- Process CSV Content and Upload HL7 ---
        message_count = process_csv_content_and_upload_hl7(
            s3_client,
            s3_bucket_name,
            output_key_template,
            s3_object_content,
            file_key_hash_prefix,
            context
        )
        
        summary = f"Processed {message_count} HL7 messages from {s3_object_key}" # Create summary message
        logger.info(summary) # Log summary
        if os.environ.get(ERROR_TOPIC_ENV_VAR): # Check if SNS topic is configured
            sns = boto3.client('sns') # Initialize SNS client
            sns.publish(TopicArn=os.environ.get(ERROR_TOPIC_ENV_VAR), Subject="CSV to HL7 Success", Message=summary) # Publish success message

    return {"status": "csv processing complete"} # Return success status
