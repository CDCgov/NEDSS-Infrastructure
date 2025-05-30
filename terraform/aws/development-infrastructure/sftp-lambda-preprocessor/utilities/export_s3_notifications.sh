#!/usr/bin/env bash
# Usage: ./export_s3_notifications.sh <bucket-name>
# Requires: jq, aws CLI

set -euo pipefail

BUCKET_NAME="$1"
EXPORT_FILE="terraform_notifications.tf"

echo "Fetching S3 notification configuration for bucket: $BUCKET_NAME..."

aws s3api get-bucket-notification-configuration --bucket "$BUCKET_NAME" > tmp_notifications.json

echo "" > "$EXPORT_FILE"

LAMBDA_COUNT=$(jq '.LambdaFunctionConfigurations | length' tmp_notifications.json)
if [ "$LAMBDA_COUNT" -eq 0 ]; then
  echo "No LambdaFunctionConfigurations found in bucket."
else
  for i in $(seq 0 $((LAMBDA_COUNT - 1))); do
    LAMBDA_ARN=$(jq -r ".LambdaFunctionConfigurations[$i].LambdaFunctionArn" tmp_notifications.json)
    PREFIX=$(jq -r ".LambdaFunctionConfigurations[$i].Filter.Key.FilterRules[] | select(.Name == \"prefix\").Value" tmp_notifications.json)
    SUFFIX=$(jq -r ".LambdaFunctionConfigurations[$i].Filter.Key.FilterRules[] | select(.Name == \"suffix\").Value" tmp_notifications.json)

    cat <<EOT >> "$EXPORT_FILE"
{
  prefix     = "${PREFIX}"
  suffix     = "${SUFFIX}"
  lambda_arn = "${LAMBDA_ARN}"
},
EOT
  done

  echo "Terraform-compatible trigger blocks written to: $EXPORT_FILE"
fi

#rm -f tmp_notifications.json
