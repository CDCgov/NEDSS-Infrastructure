# Terraform AWS Module: 1-nbs7/aws-prometheus-grafana/prometheus-helm

## Description

This module is used to deploy and configure the Prometheus Helm chart and related resources for NBS7.

<!-- BEGIN_TF_DOCS -->

## Requirements

No requirements.

## Providers

| Name                                                | Version |
| --------------------------------------------------- | ------- |
| <a name="provider_helm"></a> [helm](#provider_helm) | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                                            | Type     |
| --------------------------------------------------------------------------------------------------------------- | -------- |
| [helm_release.prometheus](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name                                                                                                                           | Description                                                                        | Type     | Default | Required |
| ------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------- | -------- | ------- | :------: |
| <a name="input_chart"></a> [chart](#input_chart)                                                                               | The name of the Helm chart                                                         | `string` | n/a     |   yes    |
| <a name="input_dependency_update"></a> [dependency_update](#input_dependency_update)                                           | Set to true to update the Helm chart dependencies before install                   | `bool`   | n/a     |   yes    |
| <a name="input_force_update"></a> [force_update](#input_force_update)                                                          | Set to true to force resource updates through a replace operation                  | `bool`   | n/a     |   yes    |
| <a name="input_iam_proxy_prometheus_role_arn"></a> [iam_proxy_prometheus_role_arn](#input_iam_proxy_prometheus_role_arn)       | The ARN of the IAM role used by the Prometheus proxy                               | `string` | n/a     |   yes    |
| <a name="input_lint"></a> [lint](#input_lint)                                                                                  | Set to true to lint the Helm chart before install                                  | `bool`   | n/a     |   yes    |
| <a name="input_namespace_name"></a> [namespace_name](#input_namespace_name)                                                    | The name of the Kubernetes namespace                                               | `string` | n/a     |   yes    |
| <a name="input_region"></a> [region](#input_region)                                                                            | The AWS region to use for the resources                                            | `string` | n/a     |   yes    |
| <a name="input_repository"></a> [repository](#input_repository)                                                                | The URL of the Helm chart repository                                               | `string` | n/a     |   yes    |
| <a name="input_service_account_amp_ingest_name"></a> [service_account_amp_ingest_name](#input_service_account_amp_ingest_name) | The name of the service account used to ingest data into Amazon Managed Prometheus | `string` | n/a     |   yes    |
| <a name="input_workspace_id"></a> [workspace_id](#input_workspace_id)                                                          | The ID of the Amazon Managed Prometheus workspace                                  | `string` | n/a     |   yes    |

## Outputs

No outputs.

<!-- END_TF_DOCS -->
