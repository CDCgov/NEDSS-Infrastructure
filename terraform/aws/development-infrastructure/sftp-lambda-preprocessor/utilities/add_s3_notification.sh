#!/usr/bin/env bash
# Manually add S3 notification for prefix/suffix/Lambda combination

set -euo pipefail

# === Default Configuration ===
DEFAULT_BUCKET="my-s3-bucket"
DEFAULT_SITE="sitename"
DEFAULT_LAB="labname"
DEFAULT_PREFIX="incoming/"
DEFAULT_SUFFIX=".csv"
DEFAULT_ACCOUNT=1234567890123

LAMBDA_OPTIONS=(
  "arn:aws:lambda:us-east-1:$DEFAULT_ACCOUNT:function:split_csv_lambda"
  "arn:aws:lambda:us-east-1:$DEFAULT_ACCOUNT:function:split_dat_lambda"
  "arn:aws:lambda:us-east-1:$DEFAULT_ACCOUNT:function:split_obr_lambda"
)

# === Prompting with Defaults ===
read -p "S3 Bucket [${DEFAULT_BUCKET}]: " BUCKET
BUCKET="${BUCKET:-$DEFAULT_BUCKET}"

read -p "Site name [${DEFAULT_SITE}]: " SITE
SITE="${SITE:-$DEFAULT_SITE}"

read -p "Lab name [${DEFAULT_LAB}]: " LAB
LAB="${LAB:-$DEFAULT_LAB}"

read -p "Prefix path [${DEFAULT_PREFIX}]: " PREFIX
PREFIX="${PREFIX:-$DEFAULT_PREFIX}"

read -p "Suffix [${DEFAULT_SUFFIX}]: " SUFFIX
SUFFIX="${SUFFIX:-$DEFAULT_SUFFIX}"

echo "Choose Lambda to trigger:"
select LAMBDA_ARN in "${LAMBDA_OPTIONS[@]}"; do
  [[ -n "$LAMBDA_ARN" ]] && break
done

FULL_PREFIX="${SITE}/${LAB}/${PREFIX}"

echo "Creating notification for:"
echo "  Bucket:       $BUCKET"
echo "  Prefix:       $FULL_PREFIX"
echo "  Suffix:       $SUFFIX"
echo "  Lambda ARN:   $LAMBDA_ARN"

# === Get existing configuration
aws s3api get-bucket-notification-configuration --bucket "$BUCKET" > config.json

# === Build new entry
NEW_CONFIG=$(jq --arg arn "$LAMBDA_ARN" --arg prefix "$FULL_PREFIX" --arg suffix "$SUFFIX"   '.LambdaFunctionConfigurations += [{
    Id: ("manual-notify-" + ($prefix | gsub("[^a-zA-Z0-9]"; "-")) + "-" + ($suffix | gsub("[^a-zA-Z0-9]"; ""))),
    LambdaFunctionArn: $arn,
    Events: ["s3:ObjectCreated:*"],
    Filter: {
      Key: {
        FilterRules: [
          { Name: "prefix", Value: $prefix },
          { Name: "suffix", Value: $suffix }
        ]
      }
    }
  }]' config.json)

echo "$NEW_CONFIG" > updated_config.json

# === Apply updated configuration
aws s3api put-bucket-notification-configuration --bucket "$BUCKET" --notification-configuration file://updated_config.json

echo "Notification successfully added."

rm -f config.json updated_config.json
