import boto3
import os
import urllib.parse
from datetime import datetime

s3 = boto3.client("s3")
sns = boto3.client("sns")
dynamo = boto3.resource("dynamodb")
error_table = dynamo.Table("hl7-error-log")

def log_error(file_name, reason):
    timestamp = datetime.utcnow().isoformat()
    error_table.put_item(Item={
        "FileName": file_name,
        "Timestamp": timestamp,
        "Reason": reason
    })
    try:
        parts = file_name.split("/")
        site = parts[1] if len(parts) > 1 else "unknown"
        publisher = parts[2] if len(parts) > 2 else "unknown"
        sns.publish(
            TopicArn=os.environ["ERROR_TOPIC_ARN"],
            Subject=f"HL7 Processing Error: {site}/{publisher}",
            Message=(
                f"🚨 HL7 Error\n\n"
                f"File: {file_name}\n"
                f"Reason: {reason}\n"
                f"Timestamp: {timestamp}"
            )
        )
    except Exception as e:
        print(f"Failed to send SNS error: {e}")

def log_success(file_name, count, site, publisher):
    timestamp = datetime.utcnow().isoformat()
    try:
        sns.publish(
            TopicArn=os.environ["SUCCESS_TOPIC_ARN"],
            Subject=f"HL7 Processed: {site}/{publisher}",
            Message=(
                f"✅ HL7 Message Processed\n\n"
                f"File: {file_name}\n"
                f"Segments Split: {count}\n"
                f"Timestamp: {timestamp}"
            )
        )
    except Exception as e:
        print(f"Failed to send SNS success: {e}")

def split_obrs(hl7_text):
    lines = hl7_text.strip().splitlines()
    msh = next((l for l in lines if l.startswith("MSH|")), None)
    pid = next((l for l in lines if l.startswith("PID|")), "")
    if not msh:
        return []

    obr_groups = []
    current_group = []
    for line in lines:
        if line.startswith("OBR|"):
            if current_group:
                obr_groups.append(current_group)
            current_group = [line]
        elif line.startswith("OBX|") and current_group:
            current_group.append(line)
    if current_group:
        obr_groups.append(current_group)

    return [f"{msh}\n{pid}\n" + "\n".join(group) for group in obr_groups]

def extract_testcode_and_date(obr_line):
    fields = obr_line.split("|")
    test_code = fields[4].split("^")[0] if len(fields) > 4 else "UNKNOWN"
    raw_date = fields[7] if len(fields) > 7 else ""
    try:
        dt = datetime.strptime(raw_date[:12], "%Y%m%d%H%M")
        obs_date = dt.strftime("%Y%m%d%H%M")
    except Exception:
        obs_date = "000000000000"
    return test_code, obs_date

def lambda_handler(event, context):
    for record in event["Records"]:
        src_bucket = record["s3"]["bucket"]["name"]
        src_key = urllib.parse.unquote_plus(record["s3"]["object"]["key"])
        _, ext = os.path.splitext(src_key)

        if ext.lower() not in [".hl7", ".txt"]:
            log_error(src_key, "Unsupported file extension")
            continue

        try:
            obj = s3.get_object(Bucket=src_bucket, Key=src_key)
            content = obj["Body"].read().decode("utf-8")
        except Exception as e:
            log_error(src_key, f"Error reading file: {e}")
            continue

        if not content.startswith("MSH|"):
            log_error(src_key, "Invalid HL7 format (missing MSH)")
            continue

        parts = src_key.split("/")
        if len(parts) < 4:
            log_error(src_key, "Unexpected path format")
            continue

        site = parts[1]
        publisher = parts[2]
        filename = parts[-1].rsplit(".", 1)[0]

        messages = split_obrs(content)
        if not messages:
            log_error(src_key, "No OBR segments found")
            continue

        for i, msg in enumerate(messages):
            obr_line = next((l for l in msg.splitlines() if l.startswith("OBR|")), "")
            test_code, obs_date = extract_testcode_and_date(obr_line)
            part_key = f"sites/{site}/inbox/{publisher}/{filename}_OBR{i+1}_{test_code}_{obs_date}.hl7"
            try:
                s3.put_object(Bucket=src_bucket, Key=part_key, Body=msg.encode("utf-8"))
            except Exception as e:
                log_error(part_key, f"Failed to write part: {e}")

        log_success(src_key, len(messages), site, publisher)
