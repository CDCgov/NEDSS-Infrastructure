#!/bin/bash

# define some functions used in lots of scripting, need to remove duplication
# log debug debug_message log_debug  pause_step step_pause load_defaults update_defaults resolve_secret prompt_for_value check_for_placeholders
source "$(dirname "$0")/../../common_functions.sh"

#DEBUG=1
PROFILE_NAME="example-terraform"
ROLE_NAME="example-terraform-user"  # Replace with your role's name
echo "edit line 8,9 and comment exit and rerun"
exit 1

RC_FILE=delete-s3-bucket-objects-before-terraform-destroy.rc
if [ -r ${RC_FILE} ]
then
    . ${RC_FILE}
fi

#debug_prompt() {
#    if [ "$DEBUG" -eq 1 ]; then
#        echo "[DEBUG] $1"
#        read -p "Press enter to continue..."
#    fi
#}

# Check if the profile exists
debug_prompt "Checking if profile $PROFILE_NAME exists..."
aws configure list --profile "$PROFILE_NAME" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Error: The profile $PROFILE_NAME does not exist in AWS credentials."
    exit 1
fi

# Extract the account ID from the Terraform state
debug_prompt "Fetching account ID from Terraform state..."
ACCOUNT_ID=$(terraform state show module.fluentbit.module.fluentbit-bucket.data.aws_caller_identity.current | grep "account_id\s*=" | cut -d'=' -f2 | tr -d ' "')
if [ -z "$ACCOUNT_ID" ]; then
    echo "Error: Failed to fetch account ID from Terraform state."
    exit 1
fi
debug_prompt "Account ID: $ACCOUNT_ID"

# Extract the S3 bucket name from the Terraform state
debug_prompt "Fetching S3 bucket name from Terraform state..."
BUCKET_NAME=$(terraform state show module.fluentbit.module.fluentbit-bucket.aws_s3_bucket.log_bucket | grep "bucket\s*=" | cut -d'=' -f2 | tr -d ' "')
if [ -z "$BUCKET_NAME" ]; then
    echo "Error: Failed to fetch S3 bucket name from Terraform state."
    exit 1
fi
debug_prompt "S3 bucket name: $BUCKET_NAME"

# Assume the role using the specified profile
debug_prompt "Assuming role $ROLE_NAME using profile $PROFILE_NAME..."
ROLE_SESSION_NAME="S3DeletionSession"
echo aws sts assume-role --role-arn arn:aws:iam::"$ACCOUNT_ID":role/"$ROLE_NAME" --role-session-name "$ROLE_SESSION_NAME" --profile "$PROFILE_NAME"
CREDENTIALS=$(aws sts assume-role --role-arn arn:aws:iam::"$ACCOUNT_ID":role/"$ROLE_NAME" --role-session-name "$ROLE_SESSION_NAME" --profile "$PROFILE_NAME")
if [ $? -ne 0 ]; then
    echo "Error: Failed to assume role $ROLE_NAME."
    echo "Error: ignoring for now"
#    exit 1
fi
#debug_prompt "Role assumed successfully."

#export AWS_ACCESS_KEY_ID=$(echo $CREDENTIALS | jq -r .Credentials.AccessKeyId)
#export AWS_SECRET_ACCESS_KEY=$(echo $CREDENTIALS | jq -r .Credentials.SecretAccessKey)
#export AWS_SESSION_TOKEN=$(echo $CREDENTIALS | jq -r .Credentials.SessionToken)

debug_prompt "You are about to recursively delete objects in the following folders of the bucket $BUCKET_NAME:"
echo "- log/"
echo "- service/"

read -p "Are you sure you want to delete objects in these folders? [y/N] " -r

if [[ $REPLY =~ ^[Yy]$ ]]; then
    debug_prompt "Recursively deleting objects in the 'log' folder..."
    aws s3 rm s3://"$BUCKET_NAME"/log/ --recursive
    if [ $? -ne 0 ]; then
        echo "Error: Failed to delete objects in the 'logs' folder."
        exit 1
    fi

    debug_prompt "Recursively deleting objects in the 'service' folder..."
    aws s3 rm s3://"$BUCKET_NAME"/service/ --recursive
    if [ $? -ne 0 ]; then
        echo "Error: Failed to delete objects in the 'service' folder."
        exit 1
    fi

    echo "Objects deleted successfully."
else
    echo "Operation cancelled."
fi

# Clean up environment variables after the operation
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN

