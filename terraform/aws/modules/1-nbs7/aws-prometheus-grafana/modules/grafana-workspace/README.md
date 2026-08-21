# Terraform AWS Module: 1-nbs7/aws-prometheus-grafana/grafana-workspace

## Description

This module deploys and configures the Grafana workspace and related resources for NBS7.

## Module Details

<!-- BEGIN_TF_DOCS -->

### Requirements

| Name                                                                     | Version           |
| ------------------------------------------------------------------------ | ----------------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.15.6         |
| <a name="requirement_grafana"></a> [grafana](#requirement_grafana)       | >=4.19.0, < 5.0.0 |

### Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | n/a     |

### Resources

| Name                                                                                                                                                                | Type     |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_grafana_workspace.amg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/grafana_workspace)                                          | resource |
| [aws_grafana_workspace_service_account.terraform_sa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/grafana_workspace_service_account) | resource |
| [aws_iam_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                                     | resource |
| [aws_iam_policy_attachment.grafana-attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment)                       | resource |
| [aws_iam_role.grafana_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                   | resource |

### Inputs

| Name                                                                                                | Description                                                | Type          | Default                              | Required |
| --------------------------------------------------------------------------------------------------- | ---------------------------------------------------------- | ------------- | ------------------------------------ | :------: |
| <a name="input_amp_workspace_id"></a> [amp_workspace_id](#input_amp_workspace_id)                   | The ID of the Amazon Managed Prometheus workspace.         | `string`      | n/a                                  |   yes    |
| <a name="input_endpoint_url"></a> [endpoint_url](#input_endpoint_url)                               | The URL of the Prometheus workspace endpoint               | `string`      | n/a                                  |   yes    |
| <a name="input_grafana_workspace_name"></a> [grafana_workspace_name](#input_grafana_workspace_name) | The name of the Grafana workspace                          | `string`      | n/a                                  |   yes    |
| <a name="input_region"></a> [region](#input_region)                                                 | The AWS region to use for the resources                    | `string`      | n/a                                  |   yes    |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix)                      | The prefix text to add to the start of each resource name  | `string`      | n/a                                  |   yes    |
| <a name="input_tags"></a> [tags](#input_tags)                                                       | A map of tags to add to resources                          | `map(string)` | n/a                                  |   yes    |
| <a name="input_data_sources"></a> [data_sources](#input_data_sources)                               | The data source for Grafana. Only Prometheus is supported. | `list(any)`   | <pre>[<br/> "PROMETHEUS"<br/>]</pre> |    no    |

### Outputs

| Name                                                                                                                                | Description                                                           |
| ----------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------- |
| <a name="output_amg-workspace-id"></a> [amg-workspace-id](#output_amg-workspace-id)                                                 | The ID of the Grafana workspace                                       |
| <a name="output_amg-workspace-service-account-id"></a> [amg-workspace-service-account-id](#output_amg-workspace-service-account-id) | The ID of the Grafana service account for Terraform (numeric ID only) |
| <a name="output_amg-workspace_arn"></a> [amg-workspace_arn](#output_amg-workspace_arn)                                              | n/a                                                                   |
| <a name="output_amg-workspace_endpoint"></a> [amg-workspace_endpoint](#output_amg-workspace_endpoint)                               | n/a                                                                   |
| <a name="output_amg-workspace_version"></a> [amg-workspace_version](#output_amg-workspace_version)                                  | n/a                                                                   |

<!-- END_TF_DOCS -->
