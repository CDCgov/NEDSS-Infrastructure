# Terraform AWS Module: 1-nbs7/aws-prometheus-grafana/grafana-token-rotation

## Description

This module is used to deploy and configure resources to support Grafana token rotation for NBS7.

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version           |
| ------------------------------------------------------------------------ | ----------------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.15.6         |
| <a name="requirement_grafana"></a> [grafana](#requirement_grafana)       | >=4.19.0, < 5.0.0 |

## Providers

| Name                                                         | Version |
| ------------------------------------------------------------ | ------- |
| <a name="provider_archive"></a> [archive](#provider_archive) | n/a     |
| <a name="provider_aws"></a> [aws](#provider_aws)             | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                 | Type        |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_cloudwatch_event_rule.rotation_schedule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule)                     | resource    |
| [aws_cloudwatch_event_target.lambda_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target)                     | resource    |
| [aws_cloudwatch_log_group.lambda_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group)                             | resource    |
| [aws_iam_policy.cloudwatch_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                           | resource    |
| [aws_iam_policy.grafana_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                              | resource    |
| [aws_iam_policy.secretsmanager_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                       | resource    |
| [aws_iam_role.lambda_rotation_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                            | resource    |
| [aws_iam_role_policy_attachment.cloudwatch_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)       | resource    |
| [aws_iam_role_policy_attachment.grafana_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)          | resource    |
| [aws_iam_role_policy_attachment.secretsmanager_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)   | resource    |
| [aws_lambda_function.token_rotation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function)                                    | resource    |
| [aws_lambda_permission.allow_eventbridge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission)                             | resource    |
| [aws_secretsmanager_secret.grafana_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret)                         | resource    |
| [aws_secretsmanager_secret_version.grafana_token_initial](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource    |
| [archive_file.lambda_zip](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file)                                                   | data source |

## Inputs

| Name                                                                                                | Description                                                                        | Type          | Default | Required |
| --------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- | ------------- | ------- | :------: |
| <a name="input_grafana_workspace_id"></a> [grafana_workspace_id](#input_grafana_workspace_id)       | The ID of the Grafana workspace                                                    | `string`      | n/a     |   yes    |
| <a name="input_region"></a> [region](#input_region)                                                 | AWS region                                                                         | `string`      | n/a     |   yes    |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix)                      | Prefix for resource names                                                          | `string`      | n/a     |   yes    |
| <a name="input_rotation_schedule_days"></a> [rotation_schedule_days](#input_rotation_schedule_days) | Number of days between token rotations (should be less than token_expiration_days) | `number`      | `25`    |    no    |
| <a name="input_service_account_id"></a> [service_account_id](#input_service_account_id)             | The ID of the Grafana service account                                              | `string`      | n/a     |   yes    |
| <a name="input_tags"></a> [tags](#input_tags)                                                       | Tags to apply to resources                                                         | `map(string)` | `{}`    |    no    |
| <a name="input_token_expiration_days"></a> [token_expiration_days](#input_token_expiration_days)    | Number of days until the token expires                                             | `number`      | `30`    |    no    |

## Outputs

| Name                                                                                            | Description                                                     |
| ----------------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| <a name="output_lambda_function_arn"></a> [lambda_function_arn](#output_lambda_function_arn)    | ARN of the Lambda function that rotates the token               |
| <a name="output_lambda_function_name"></a> [lambda_function_name](#output_lambda_function_name) | Name of the Lambda function that rotates the token              |
| <a name="output_secret_arn"></a> [secret_arn](#output_secret_arn)                               | ARN of the Secrets Manager secret containing the Grafana token  |
| <a name="output_secret_id"></a> [secret_id](#output_secret_id)                                  | ID of the Secrets Manager secret containing the Grafana token   |
| <a name="output_secret_name"></a> [secret_name](#output_secret_name)                            | Name of the Secrets Manager secret containing the Grafana token |

<!-- END_TF_DOCS -->
