# Terraform AWS Module: 1-nbs7/aws-prometheus-grafana/prometheus-workspace

## Description

This module is used to deploy and configure the Prometheus workspace and related resources for NBS7.

## Module Details

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.15.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.21.0, < 7.0.0 |

### Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.21.0, < 7.0.0 |

### Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_log_group.amp_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.sns-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_attachment.sns-attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_role.amp_prometheus_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_prometheus_alert_manager_definition.alertmgr_definition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_alert_manager_definition) | resource |
| [aws_prometheus_rule_group_namespace.amp_rule_group_namespace](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_rule_group_namespace) | resource |
| [aws_prometheus_workspace.amp_workspace](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_workspace) | resource |
| [aws_sns_topic.prometheus-alerts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_alias"></a> [alias](#input\_alias) | The alias to give the resource | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The AWS region to use for the resources | `string` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | The prefix text to add to the start of each resource name | `string` | n/a | yes |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | The number of days to keep the log data | `number` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to the resources | `map(string)` | n/a | yes |

### Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_amp_workspace_endpoint"></a> [amp\_workspace\_endpoint](#output\_amp\_workspace\_endpoint) | n/a |
| <a name="output_amp_workspace_id"></a> [amp\_workspace\_id](#output\_amp\_workspace\_id) | n/a |
| <a name="output_sns_topic_arn"></a> [sns\_topic\_arn](#output\_sns\_topic\_arn) | n/a |
<!-- END_TF_DOCS -->
