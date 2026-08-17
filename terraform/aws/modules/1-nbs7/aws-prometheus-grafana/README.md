# Terraform AWS Module: 1-nbs7/aws-prometheus-grafana

## Description

This module is used to deploy and configure AWS Managed Service for Grafana, AWS Managed Service for Prometheus and related resources for NBS7.

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                        | Version            |
| --------------------------------------------------------------------------- | ------------------ |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform)    | >= 1.15.6          |
| <a name="requirement_archive"></a> [archive](#requirement_archive)          | >= 2.0.0           |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                      | >= 6.21.0, < 7.0.0 |
| <a name="requirement_grafana"></a> [grafana](#requirement_grafana)          | >= 4.19.0, < 5.0.0 |
| <a name="requirement_helm"></a> [helm](#requirement_helm)                   | >= 3.1.1, < 4.0.0  |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement_kubernetes) | >= 2.38.0, < 3.0.0 |
| <a name="requirement_null"></a> [null](#requirement_null)                   | >= 3.0.0           |

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | 6.21.0  |

## Modules

| Name                                                                                                  | Source                           | Version |
| ----------------------------------------------------------------------------------------------------- | -------------------------------- | ------- |
| <a name="module_grafana-dashboard"></a> [grafana-dashboard](#module_grafana-dashboard)                | ./modules/grafana-dashboard      | n/a     |
| <a name="module_grafana-token-rotation"></a> [grafana-token-rotation](#module_grafana-token-rotation) | ./modules/grafana-token-rotation | n/a     |
| <a name="module_grafana-workspace"></a> [grafana-workspace](#module_grafana-workspace)                | ./modules/grafana-workspace      | n/a     |
| <a name="module_iam-role"></a> [iam-role](#module_iam-role)                                           | ./modules/iam-roles              | n/a     |
| <a name="module_prometheus-helm"></a> [prometheus-helm](#module_prometheus-helm)                      | ./modules/prometheus-helm        | n/a     |
| <a name="module_prometheus-workspace"></a> [prometheus-workspace](#module_prometheus-workspace)       | ./modules/prometheus-workspace   | n/a     |

## Resources

| Name                                                                                                                                                            | Type        |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_lambda_invocation.initial_token_rotation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_invocation)                   | resource    |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)                                   | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth)                                 | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)                                                     | data source |
| [aws_secretsmanager_secret_version.grafana_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |

## Inputs

| Name                                                                                                                                    | Description                                                       | Type          | Default                                                 | Required |
| --------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------- | ------------- | ------------------------------------------------------- | :------: |
| <a name="input_chart"></a> [chart](#input_chart)                                                                                        | The name of the Prometheus Helm chart                             | `string`      | `"prometheus"`                                          |    no    |
| <a name="input_cluster_certificate_authority_data"></a> [cluster_certificate_authority_data](#input_cluster_certificate_authority_data) | The base64-encoded certificate data needed to talk to the cluster | `string`      | n/a                                                     |   yes    |
| <a name="input_data_sources"></a> [data_sources](#input_data_sources)                                                                   | The list of Grafana data sources                                  | `list(any)`   | <pre>[<br/> "PROMETHEUS"<br/>]</pre>                    |    no    |
| <a name="input_dependency_update"></a> [dependency_update](#input_dependency_update)                                                    | Set to true to update the Helm chart dependencies before install  | `bool`        | `true`                                                  |    no    |
| <a name="input_eks_aws_role_arn"></a> [eks_aws_role_arn](#input_eks_aws_role_arn)                                                       | The IAM role ARN of the EKS cluster                               | `string`      | n/a                                                     |   yes    |
| <a name="input_eks_cluster_endpoint"></a> [eks_cluster_endpoint](#input_eks_cluster_endpoint)                                           | The endpoint of the EKS cluster                                   | `string`      | n/a                                                     |   yes    |
| <a name="input_eks_cluster_name"></a> [eks_cluster_name](#input_eks_cluster_name)                                                       | The name of the EKS cluster                                       | `string`      | n/a                                                     |   yes    |
| <a name="input_force_update"></a> [force_update](#input_force_update)                                                                   | Set to true to force resource updates through a replace operation | `bool`        | `true`                                                  |    no    |
| <a name="input_lint"></a> [lint](#input_lint)                                                                                           | Set to true to lint the Helm chart before install                 | `bool`        | `true`                                                  |    no    |
| <a name="input_namespace_name"></a> [namespace_name](#input_namespace_name)                                                             | The name of the Kubernetes namespace                              | `string`      | `"observability"`                                       |    no    |
| <a name="input_oidc_provider_arn"></a> [oidc_provider_arn](#input_oidc_provider_arn)                                                    | The ARN of the OIDC provider                                      | `string`      | n/a                                                     |   yes    |
| <a name="input_oidc_provider_url"></a> [oidc_provider_url](#input_oidc_provider_url)                                                    | The URL of the OIDC provider                                      | `string`      | n/a                                                     |   yes    |
| <a name="input_region"></a> [region](#input_region)                                                                                     | The AWS region to use for the resources                           | `string`      | `"us-east-1"`                                           |    no    |
| <a name="input_repository"></a> [repository](#input_repository)                                                                         | The URL of the Prometheus Helm chart repository                   | `string`      | `"https://prometheus-community.github.io/helm-charts/"` |    no    |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix)                                                          | Prefix for resource names                                         | `string`      | `"cdc-nbs"`                                             |    no    |
| <a name="input_retention_in_days"></a> [retention_in_days](#input_retention_in_days)                                                    | The number of days to keep the log data                           | `number`      | `30`                                                    |    no    |
| <a name="input_tags"></a> [tags](#input_tags)                                                                                           | A map of tags to add to the resources                             | `map(string)` | n/a                                                     |   yes    |

## Outputs

| Name                                                                                                                       | Description                                                     |
| -------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| <a name="output_amg-workspace-id"></a> [amg-workspace-id](#output_amg-workspace-id)                                        | The ID of the Grafana workspace                                 |
| <a name="output_amg-workspace_endpoint"></a> [amg-workspace_endpoint](#output_amg-workspace_endpoint)                      | The endpoint of the Grafana workspace                           |
| <a name="output_amp_workspace_endpoint"></a> [amp_workspace_endpoint](#output_amp_workspace_endpoint)                      | The endpoint of the Prometheus workspace                        |
| <a name="output_amp_workspace_id"></a> [amp_workspace_id](#output_amp_workspace_id)                                        | The ID of the Prometheus workspace                              |
| <a name="output_grafana-token-rotation-lambda"></a> [grafana-token-rotation-lambda](#output_grafana-token-rotation-lambda) | Name of the Lambda function that rotates the Grafana token      |
| <a name="output_grafana-token-secret-arn"></a> [grafana-token-secret-arn](#output_grafana-token-secret-arn)                | ARN of the Secrets Manager secret containing the Grafana token  |
| <a name="output_grafana-token-secret-name"></a> [grafana-token-secret-name](#output_grafana-token-secret-name)             | Name of the Secrets Manager secret containing the Grafana token |
| <a name="output_prometheus_role_arn"></a> [prometheus_role_arn](#output_prometheus_role_arn)                               | The ARN of the Prometheus IAM role                              |
| <a name="output_sns_topic_arn"></a> [sns_topic_arn](#output_sns_topic_arn)                                                 | The ARN of the SNS topic for Prometheus alerts                  |

<!-- END_TF_DOCS -->
