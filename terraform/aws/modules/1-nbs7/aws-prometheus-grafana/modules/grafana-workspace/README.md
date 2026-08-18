# Terraform AWS Module: 1-nbs7/aws-prometheus-grafana/grafana-workspace

## Description

This module is used to deploy and configure the Grafana workspace and related resources for NBS7.

## Module Details

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.15.6 |
| <a name="requirement_grafana"></a> [grafana](#requirement\_grafana) | >=4.19.0, < 5.0.0 |

### Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

### Resources

| Name | Type |
| ---- | ---- |
| [aws_grafana_workspace.amg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/grafana_workspace) | resource |
| [aws_grafana_workspace_service_account.terraform_sa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/grafana_workspace_service_account) | resource |
| [aws_iam_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_attachment.grafana-attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_role.grafana_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_amp_workspace_id"></a> [amp\_workspace\_id](#input\_amp\_workspace\_id) | The ID of the Amazon Managed Prometheus workspace. | `string` | n/a | yes |
| <a name="input_endpoint_url"></a> [endpoint\_url](#input\_endpoint\_url) | The URL of the endpoint | `string` | n/a | yes |
| <a name="input_grafana_workspace_name"></a> [grafana\_workspace\_name](#input\_grafana\_workspace\_name) | The name of the Grafana workspace | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The AWS region to use for the resources | `string` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | The prefix text to add to the start of each resource name | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to resources | `map(string)` | n/a | yes |
| <a name="input_data_sources"></a> [data\_sources](#input\_data\_sources) | the datasource for grafana; in this case Prometheus | `list(any)` | <pre>[<br/>  "PROMETHEUS"<br/>]</pre> | no |

### Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_amg-workspace-id"></a> [amg-workspace-id](#output\_amg-workspace-id) | The ID of the Grafana workspace |
| <a name="output_amg-workspace-service-account-id"></a> [amg-workspace-service-account-id](#output\_amg-workspace-service-account-id) | The ID of the Grafana service account for Terraform (numeric ID only) |
| <a name="output_amg-workspace_arn"></a> [amg-workspace\_arn](#output\_amg-workspace\_arn) | n/a |
| <a name="output_amg-workspace_endpoint"></a> [amg-workspace\_endpoint](#output\_amg-workspace\_endpoint) | n/a |
| <a name="output_amg-workspace_version"></a> [amg-workspace\_version](#output\_amg-workspace\_version) | n/a |
<!-- END_TF_DOCS -->
