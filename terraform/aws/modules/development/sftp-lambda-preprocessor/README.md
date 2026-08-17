# Terraform AWS Module: development/sftp-lambda-preprocessor

## Description

This module is used to deploy and configure NBS7 development resources for CSV to HL7 Transformer Lambda

This module:

- Creates three SNS topics for notifications
- Deploys three Lambda functions that
- converts each row in an uploaded CSV file to HL7 format
- splits a multi HL7 message "dat" file
- untested code to split a multi OBR HL7 message
- Triggers Lambda on `csv,dat,hl7` uploads to the specified S3 bucket, currently the triggers are based on one users incoming directory, others can be modified/added manually
- Publishes success/error results to SNS
- subscribes an email address to SNS topics (confirm before uploading test files)
- creates and poulate a cloudwatch metric from split_dat (need to add this to older lambdas)

## How to Use

1. run regenerate_lambda_zips.sh to recreate zip files in build directory
2. Update `terraform.tfvars` with your actual S3 bucket name.
3. add an email address to get sns notifications
4. Run the following:

```bash
terraform init
terraform apply
```

## Output

- HL7 files are stored in `<s3bucket>/<site_name>/<username>/splitcsv, splitdat, splitobr` within the same bucket.
- One HL7 message per row in the CSV.

<!-- BEGIN_TF_DOCS -->

## Requirements

No requirements.

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                                                                                          | Type     |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_iam_policy.lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                        | resource |
| [aws_iam_role.lambda_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                              | resource |
| [aws_iam_role_policy_attachment.lambda_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.split_csv_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function)                           | resource |
| [aws_lambda_function.split_dat_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function)                           | resource |
| [aws_lambda_function.split_obr_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function)                           | resource |
| [aws_lambda_permission.allow_s3_to_invoke_split_csv](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission)           | resource |
| [aws_lambda_permission.allow_s3_to_invoke_split_dat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission)           | resource |
| [aws_lambda_permission.allow_s3_to_invoke_split_obr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission)           | resource |
| [aws_sns_topic.split_csv_errors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic)                                       | resource |
| [aws_sns_topic.split_csv_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic)                                        | resource |
| [aws_sns_topic.split_dat_errors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic)                                       | resource |
| [aws_sns_topic.split_obr_errors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic)                                       | resource |
| [aws_sns_topic_subscription.split_csv_email](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription)              | resource |
| [aws_sns_topic_subscription.split_dat_email](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription)              | resource |
| [aws_sns_topic_subscription.split_obr_email](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription)              | resource |

## Inputs

| Name                                                                                       | Description                                              | Type     | Default                | Required |
| ------------------------------------------------------------------------------------------ | -------------------------------------------------------- | -------- | ---------------------- | :------: |
| <a name="input_alert_email_address"></a> [alert_email_address](#input_alert_email_address) | Email address to subscribe to Lambda error notifications | `string` | n/a                    |   yes    |
| <a name="input_filter_prefix"></a> [filter_prefix](#input_filter_prefix)                   | S3 key prefix to trigger the Lambda function             | `string` | `"site/lab/incoming/"` |    no    |
| <a name="input_sftp_bucket_name"></a> [sftp_bucket_name](#input_sftp_bucket_name)          | The name of the S3 bucket used by AWS Transfer Family    | `string` | n/a                    |   yes    |

## Outputs

| Name                                                                       | Description |
| -------------------------------------------------------------------------- | ----------- |
| <a name="output_sns_topic_arn"></a> [sns_topic_arn](#output_sns_topic_arn) | n/a         |

<!-- END_TF_DOCS -->
