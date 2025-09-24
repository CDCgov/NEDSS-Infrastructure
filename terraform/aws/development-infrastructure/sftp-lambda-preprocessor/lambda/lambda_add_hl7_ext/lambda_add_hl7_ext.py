import boto3
import os
import logging
import json
import traceback
import re
import urllib.parse
from datetime import datetime
from botocore.exceptions import ClientError

# Optional: if you package the 'hl7' library with your Lambda, you can set USE_HL7_LIB=True to
# rely on it for parsing. This script uses string parsing so it can run without that dependency.
USE_HL7_LIB = False
try:
    if USE_HL7_LIB:
        import hl7  # package with your Lambda if you enable this
except Exception:
    USE_HL7_LIB = False

# ------------------------------
# Configuration
# ------------------------------
ERROR_TOPIC_ENV_VAR = "ERROR_TOPIC_ARN"

INPUT_REQUIRED_SUBDIR = "incoming"
OUTPUT_SUBDIR = "renamed_file"
OUTPUT_FILE_EXTENSION = "hl7"

# Avoid recursive processing
PROCESSED_SUBDIRS = [OUTPUT_SUBDIR]

# S3 transient error handling
MAX_S3_RETRIES = 3
RETRYABLE_S3_ERRORS = {"NoSuchKey", "SlowDown", "InternalError", "RequestTimeout", "ThrottlingException"}

# Validation config for HL7 elements
# Accept a broad HL7 TS pattern (YYYY[MM[DD[HH[MM[SS[.S{1,4}]]]]]][+/-ZZZZ])
HL7_TS_REGEX = re.compile(r'^\d{4}(\d{2}(\d{2}(\d{2}(\d{2}(\d{2}(\.\d{1,4})?)?)?)?)?)?([+\-]\d{4})?$')

# CDC/HL7 common code systems for race/ethnicity
ALLOWED_CODE_SYSTEMS = {"CDCREC", "HL70005"}
# Common CDCREC codes for race
ALLOWED_RACE_CODES = {"1002-5", "2028-9", "2054-5", "2106-3", "2076-8", "2131-1"}
# OMB Ethnicity codes
ALLOWED_ETHNICITY_CODES = {"2135-2", "2186-5"}

# ------------------------------
# Clients & Logger
# ------------------------------
s3_client = boto3.client("s3")
sns_client = boto3.client("sns")

logger = logging.getLogger()
if not logger.handlers:
    logging.basicConfig(level=logging.INFO)
logger.setLevel(logging.INFO)


# ------------------------------
# Utilities
# ------------------------------
def report_error(error_msg: str, context) -> None:
    """
    Log the error and (optionally) publish to SNS if ERROR_TOPIC_ARN is set.
    """
    logger.error(error_msg)
    try:
        topic_arn = os.environ.get(ERROR_TOPIC_ENV_VAR)
        if topic_arn:
            sns_client.publish(
                TopicArn=topic_arn,
                Subject=f"Lambda Error in {getattr(context, 'function_name', 'unknown_function')}",
                Message=error_msg,
            )
    except Exception as e:
        logger.warning("SNS publish failed: %s", str(e))


def get_s3_object_content(bucket: str, key: str) -> str:
    """
    Read S3 object with retries on common transient errors.
    """
    last_err = None
    for attempt in range(1, MAX_S3_RETRIES + 1):
        try:
            obj = s3_client.get_object(Bucket=bucket, Key=key)
            body = obj["Body"].read().decode("utf-8", errors="replace")
            logger.info("Successfully retrieved s3://%s/%s on attempt %d", bucket, key, attempt)
            return body
        except ClientError as e:
            code = e.response.get("Error", {}).get("Code")
            if code in RETRYABLE_S3_ERRORS:
                logger.warning("Retryable S3 error (%s) on attempt %d for %s: %s", code, attempt, key, str(e))
                last_err = e
            else:
                logger.error("Non-retryable S3 error for %s: %s", key, str(e))
                raise
        except Exception as e:
            logger.warning("Generic error on attempt %d for %s: %s", attempt, key, str(e))
            last_err = e
    # Exhausted retries
    if last_err:
        raise last_err
    raise RuntimeError(f"Failed to read s3://{bucket}/{key} for unknown reasons")


def normalize_hl7_line_endings(text: str) -> str:
    """
    Convert any \r\n or \n to HL7-standard \r; ensure message ends with \r.
    """
    # Normalize first to \n, then to \r
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    text = text.replace("\n", "\r")
    if not text.endswith("\r"):
        text += "\r"
    return text


def valid_ts(value: str) -> bool:
    """
    Rough validation for HL7 TS (timestamp) datatype.
    """
    if not value:
        return False
    return bool(HL7_TS_REGEX.match(value))


def _split_fields(segment_line: str) -> list:
    """
    Split an HL7 segment line into fields by '|' preserving trailing empties.
    """
    # Keep trailing empties by manual split
    parts = segment_line.rstrip("\r").split("|")
    return parts


def _join_fields(parts: list) -> str:
    """
    Rejoin fields with '|', ensure trailing empties preserved by simple join.
    """
    return "|".join(parts)


def scrub_repeat_field(field_val: str, allowed_codes: set) -> str:
    """
    For PID-10 (Race) and PID-22 (Ethnic Group):
    - Repeats separated by '~'
    - Component pattern: identifier ^ text ^ codingSystem ^ ...
    Keep only repeats whose identifier is in allowed_codes and codingSystem in ALLOWED_CODE_SYSTEMS.
    """
    if not field_val:
        return field_val
    repeats = field_val.split("~")
    kept = []
    for rep in repeats:
        comps = rep.split("^")
        code = comps[0] if len(comps) > 0 else ""
        system = comps[2] if len(comps) > 2 else ""
        if code in allowed_codes and system in ALLOWED_CODE_SYSTEMS:
            kept.append(rep)
    return "~".join(kept)


def validate_and_clean_hl7(message_text: str) -> str:
    """
    Perform lightweight validation similar to the splitter function:
      - check MSH-7 TS
      - warn on missing PID-3 (Identifier List) and PID-5 (Name)
      - validate PID-7 (DOB) and PID-33 (Last Update D/T); clear PID-33 if invalid
      - scrub PID-10 (Race) and PID-22 (Ethnic Group) to allowed code sets
      - append NTE|1|L|{collected_notes} after ORC if ORC-23.9 is populated
    Handles both single-message and batch files (multiple MSH segments)
    Returns the cleaned message text (line endings normalized).
    """
    text = normalize_hl7_line_endings(message_text)

    all_lines = [ln for ln in text.split("\r") if ln]  # drop the final empty after trailing \r

    # Group lines into batch wrappers and MSH-started messages
    output_lines = []
    current_msg = []

    def flush_non_message_line(ln: str):
        # pass batch lines through untouched to final cleaned message
        if ln.startswith(("FHS|", "BHS|", "FTS|", "BTS|")):
            output_lines.append(ln)
            return True
        return False

    def process_single_message(msg_lines: list[str]) -> list[str]:
        # apply validation scheme to single message
        if not msg_lines:
            return []

        if not any(ln.startswith("MSH|") for ln in msg_lines):
            logger.warning("No MSH segment found, skipping validation.")
            return msg_lines[:]

        lines = msg_lines[:]

        # Validate MSH-7
        msh_idx = next((i for i, ln in enumerate(lines) if ln.startswith("MSH|")), None)
        if msh_idx is not None:
            msh_fields = _split_fields(lines[msh_idx])
            if len(msh_fields) > 6:
                msh7 = msh_fields[6]
                if not valid_ts(msh7):
                    logger.warning("MSH-7 appears malformed: '%s'", msh7)
            else:
                logger.warning("MSH segment does not have field 7 (TS).")
        else:
            logger.warning("No MSH segment found in message.")

        # Find PID
        pid_idx = next((i for i, ln in enumerate(lines) if ln.startswith("PID|")), None)
        if pid_idx is not None:
            pid_fields = _split_fields(lines[pid_idx])

            # PID-3
            pid3 = pid_fields[3] if len(pid_fields) > 3 else ""
            if not pid3:
                logger.warning("PID-3 (Patient Identifier List) is empty or missing.")

            # PID-5
            pid5 = pid_fields[5] if len(pid_fields) > 5 else ""
            if not pid5:
                logger.warning("PID-5 (Patient Name) is empty or missing.")

            # PID-7
            if len(pid_fields) > 7:
                pid7 = pid_fields[7]
                if pid7 and not valid_ts(pid7):
                    logger.warning("PID-7 (DOB) appears malformed: '%s'", pid7)

            # PID-33
            if len(pid_fields) > 33:
                pid33 = pid_fields[33]
                if pid33 and not valid_ts(pid33):
                    logger.warning("PID-33 invalid. Clearing value: '%s'", pid33)
                    pid_fields[33] = ""
                    lines[pid_idx] = _join_fields(pid_fields)

            # PID-10 Race
            if len(pid_fields) > 10:
                original = pid_fields[10]
                cleaned = scrub_repeat_field(original, ALLOWED_RACE_CODES)
                if cleaned != original:
                    logger.info("Cleaned PID-10 (Race) from '%s' to '%s'", original, cleaned)
                    pid_fields[10] = cleaned
                    lines[pid_idx] = _join_fields(pid_fields)

            # PID-22 Ethnicity
            if len(pid_fields) > 22:
                original = pid_fields[22]
                cleaned = scrub_repeat_field(original, ALLOWED_ETHNICITY_CODES)
                if cleaned != original:
                    logger.info("Cleaned PID-22 (Ethnic Group) from '%s' to '%s'", original, cleaned)
                    pid_fields[22] = cleaned
                    lines[pid_idx] = _join_fields(pid_fields)
        else:
            logger.warning("No PID segment found; skipping PID validations.")

    # Move ORC-23.9 to NTE
        new_lines = []
        orc_note = None

        for ln in lines:
            new_lines.append(ln)
            if ln.startswith("ORC|"):
                fields = _split_fields(ln)
                if len(fields) > 23 and fields[23]:
                    comps = fields[23].split("^")  # assume default separators
                    if len(comps) >= 9:
                        collected_notes = comps[8].strip()
                        if collected_notes:
                            logger.info("Collected ORC-23.9 note: '%s'", collected_notes)
                            orc_note = collected_notes
                            comps[8] = ""                       #clear ORC-23.9 to alleviate truncation error
                            fields[23] = "^".join(comps)        #rebuild field with cleaned value
                            new_lines[-1]= _join_fields(fields) #replace ORC line

        if orc_note:
            logger.info("Appending NTE at end of message from ORC-23.9.")
            new_lines.append(f"NTE|1|L|{orc_note}")

        return new_lines

    # Walk the file and group messages by MSH
    for ln in all_lines:
        if flush_non_message_line(ln):
            continue

        if ln.startswith("MSH|"):
            if current_msg:
                output_lines.extend(process_single_message(current_msg))
                current_msg = []
            current_msg.append(ln)
        else:
            if current_msg:
                current_msg.append(ln)
            else:
                # pass through lines before first MSH
                output_lines.append(ln)

    # Flush last message
    if current_msg:
        output_lines.extend(process_single_message(current_msg))

    cleaned = "\r".join(output_lines)
    if not cleaned.endswith("\r"):
        cleaned += "\r"
    return cleaned

def derive_paths_and_filename(s3_key: str) -> tuple:
    """
    Given an S3 key like .../<site>/<user>/incoming/<maybe/subdirs/>filename[.ext[.]]
    return (base_user_prefix, output_key)
      - base_user_prefix: .../<site>/<user>
      - output_key:       .../<site>/<user>/renamed_file/<base>.hl7
    """
    decoded = urllib.parse.unquote_plus(s3_key)
    parts = decoded.split("/")

    # Require '/incoming/' folder
    if INPUT_REQUIRED_SUBDIR not in parts:
        raise ValueError(f"Object key must contain '{INPUT_REQUIRED_SUBDIR}/' directory. Got: {decoded}")

    inc_idx = parts.index(INPUT_REQUIRED_SUBDIR)

    # Base user prefix is everything before 'incoming'
    base_user_prefix = "/".join(parts[:inc_idx])

    # Everything after 'incoming/' — use the **last** element as the filename
    rel_parts = parts[inc_idx + 1:]
    if not rel_parts:
        raise ValueError(f"No filename found after '{INPUT_REQUIRED_SUBDIR}/' in key: {decoded}")
    filename = rel_parts[-1]

    # Allow no extension or trailing '.'; strip trailing '.' first
    if filename.endswith("."):
        filename = filename[:-1]

    # Strip any extension if present
    base_name = filename.rsplit(".", 1)[0] if "." in filename else filename

    # Compose output key
    output_dir = f"{base_user_prefix}/{OUTPUT_SUBDIR}"
    output_key = f"{output_dir}/{base_name}.{OUTPUT_FILE_EXTENSION}"
    return base_user_prefix, output_key

def write_s3_object(bucket: str, key: str, body: str) -> None:
    s3_client.put_object(Bucket=bucket, Key=key, Body=body.encode("utf-8"))
    logger.info("Wrote object to s3://%s/%s (bytes=%d)", bucket, key, len(body.encode("utf-8")))


def _process_record(record: dict, context) -> None:
    s3_info = record.get("s3", {})
    bucket = s3_info.get("bucket", {}).get("name")
    key = s3_info.get("object", {}).get("key")

    if not bucket or not key:
        logger.warning("Record missing bucket or key. Record: %s", json.dumps(record))
        return

    decoded_key = urllib.parse.unquote_plus(key)
    logger.info("Processing s3://%s/%s", bucket, decoded_key)

    # Skip already-processed subdirs
    for sub in PROCESSED_SUBDIRS:
        if f"/{sub}/" in f"/{decoded_key}":
            logger.info("Skipping already-processed object in '%s' subdir: %s", sub, decoded_key)
            return

    # Ensure '/incoming/' is part of the path and derive output key
    try:
        base_user_prefix, output_key = derive_paths_and_filename(decoded_key)
        logger.info("Output will be: s3://%s/%s", bucket, output_key)
    except Exception as e:
        logger.warning("Key path check failed for %s: %s", decoded_key, str(e))
        return

    # Read, validate/clean, and write single file
    try:
        content = get_s3_object_content(bucket, decoded_key)
        logger.info("Read %d bytes from source file.", len(content))
        cleaned = validate_and_clean_hl7(content)
        if not cleaned.strip():
            logger.warning("Cleaned content is empty; skipping write for %s", decoded_key)
            return
        write_s3_object(bucket, output_key, cleaned)
        logger.info("Successfully processed and renamed file to %s", output_key)
    except Exception as e:
        err = f"Failed processing s3://{bucket}/{decoded_key}: {str(e)}\n{traceback.format_exc()}"
        report_error(err, context)


def lambda_handler(event, context):
    logger.info("Received event: %s", json.dumps(event))
    if not isinstance(event, dict) or "Records" not in event:
        logger.warning("Event does not contain 'Records'; nothing to do.")
        return {"status": "no records"}

    errors = 0
    for rec in event.get("Records", []):
        try:
            _process_record(rec, context)
        except Exception as e:
            errors += 1
            err = f"Unexpected failure in record processing: {str(e)}\n{traceback.format_exc()}"
            report_error(err, context)

    if errors:
        logger.error("Completed with %d errors.", errors)
        return {"status": "completed with errors", "errors": errors}
    logger.info("All records processed successfully.")
    return {"status": "ok"}
