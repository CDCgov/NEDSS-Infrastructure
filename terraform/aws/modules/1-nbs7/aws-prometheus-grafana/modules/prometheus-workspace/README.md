# Terraform AWS Module: 1-nbs7/aws-prometheus-grafana/prometheus-workspace

## Description

This module deploys and configures the Prometheus workspace and related resources for NBS7.

## Module Details

<!-- BEGIN_TF_DOCS -->

### Requirements

| Name                                                                     | Version            |
| ------------------------------------------------------------------------ | ------------------ |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.15.6          |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | >= 6.21.0, < 7.0.0 |

### Providers

| Name                                             | Version            |
| ------------------------------------------------ | ------------------ |
| <a name="provider_aws"></a> [aws](#provider_aws) | >= 6.21.0, < 7.0.0 |

### Resources

| Name                                                                                                                                                                           | Type     |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------- |
| [aws_cloudwatch_log_group.amp_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group)                                     | resource |
| [aws_iam_policy.sns-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                                            | resource |
| [aws_iam_policy_attachment.sns-attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment)                                      | resource |
| [aws_iam_role.amp_prometheus_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                       | resource |
| [aws_prometheus_alert_manager_definition.alertmgr_definition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_alert_manager_definition) | resource |
| [aws_prometheus_rule_group_namespace.amp_rule_group_namespace](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_rule_group_namespace)    | resource |
| [aws_prometheus_workspace.amp_workspace](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_workspace)                                     | resource |
| [aws_sns_topic.prometheus-alerts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic)                                                       | resource |

### Inputs

| Name                                                                                 | Description                                               | Type          | Default | Required |
| ------------------------------------------------------------------------------------ | --------------------------------------------------------- | ------------- | ------- | :------: |
| <a name="input_alias"></a> [alias](#input_alias)                                     | The alias to give the resource                            | `string`      | n/a     |   yes    |
| <a name="input_region"></a> [region](#input_region)                                  | The AWS region to use for the resources                   | `string`      | n/a     |   yes    |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix)       | The prefix text to add to the start of each resource name | `string`      | n/a     |   yes    |
| <a name="input_retention_in_days"></a> [retention_in_days](#input_retention_in_days) | The number of days to keep the log data                   | `number`      | n/a     |   yes    |
| <a name="input_tags"></a> [tags](#input_tags)                                        | A map of tags to add to the resources                     | `map(string)` | n/a     |   yes    |

### Outputs

| Name                                                                                                  | Description |
| ----------------------------------------------------------------------------------------------------- | ----------- |
| <a name="output_amp_workspace_endpoint"></a> [amp_workspace_endpoint](#output_amp_workspace_endpoint) | n/a         |
| <a name="output_amp_workspace_id"></a> [amp_workspace_id](#output_amp_workspace_id)                   | n/a         |
| <a name="output_sns_topic_arn"></a> [sns_topic_arn](#output_sns_topic_arn)                            | n/a         |

<!-- END_TF_DOCS -->
