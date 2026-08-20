# Terraform AWS Module: development/synthetics-canary

## Description

This module is used to deploy and configure NBS7 development resources for synthetic check, cloudwatch events, an sns topic and email alerts
Note: emails need to be confirmed before they will actually receive alerts,
internal confirmation emails seem to get caught in spam filter, until those
are tuned consider gmail addresses initially then manually add emails to
corresponding sns topics

## Module Details

<!-- BEGIN_TF_DOCS -->


### Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

### Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_metric_alarm.canary_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_iam_policy.canary-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.canary-role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.canary-policy-attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket.canary-output-bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_sns_topic.topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_synthetics_canary.synthetics_canary_url_monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/synthetics_canary) | resource |
| [archive_file.lambda_canary_zip](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_iam_policy_document.canary-assume-role-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.canary-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_synthetics_canary_bucket_name"></a> [synthetics\_canary\_bucket\_name](#input\_synthetics\_canary\_bucket\_name) | bucket name for synthetics output | `string` | n/a | yes |
| <a name="input_synthetics_canary_url"></a> [synthetics\_canary\_url](#input\_synthetics\_canary\_url) | A URL to use for monitoring alerts | `string` | n/a | yes |
| <a name="input_synthetics_canary_create"></a> [synthetics\_canary\_create](#input\_synthetics\_canary\_create) | Create canary required resources? | `bool` | `false` | no |
<!-- END_TF_DOCS -->
