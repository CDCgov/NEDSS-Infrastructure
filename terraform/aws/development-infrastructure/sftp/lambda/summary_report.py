import boto3
import os
from datetime import datetime, timedelta

dynamodb = boto3.resource("dynamodb")
sns = boto3.client("sns")
table = dynamodb.Table("hl7-error-log")
SUMMARY_TOPIC_ARN = os.environ["SUMMARY_TOPIC_ARN"]

def lambda_handler(event, context):
    now = datetime.utcnow()
    since = now - timedelta(days=1)

    response = table.scan()
    items = response.get("Items", [])

    summary = {}
    for item in items:
        ts = datetime.fromisoformat(item["Timestamp"])
        if ts < since:
            continue
        file = item["FileName"]
        parts = file.split("/")
        site = parts[1] if len(parts) > 1 else "unknown"
        publisher = parts[2] if len(parts) > 2 else "unknown"
        summary.setdefault(site, {}).setdefault(publisher, []).append(item["Reason"])

    message_lines = [f"📊 HL7 Summary (last 24h):\n"]
    for site, pub_data in summary.items():
        message_lines.append(f"Site: {site}")
        for pub, errors in pub_data.items():
            message_lines.append(f"  Publisher: {pub} — ❌ {len(errors)} error(s)")
        message_lines.append("")

    sns.publish(
        TopicArn=SUMMARY_TOPIC_ARN,
        Subject="Daily HL7 Summary Report",
        Message="\n".join(message_lines)
    )
