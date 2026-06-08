#!/bin/bash
# Validate HL7 uploads in the target S3 bucket

if [ -z "$1" ]; then
  echo "Usage: $0 <s3-bucket-name>"
  exit 1
fi

BUCKET=$1
PREFIX="elr/csv2hl7/"

echo "Checking for HL7 files in s3://$BUCKET/$PREFIX"
aws s3 ls s3://$BUCKET/$PREFIX --recursive
