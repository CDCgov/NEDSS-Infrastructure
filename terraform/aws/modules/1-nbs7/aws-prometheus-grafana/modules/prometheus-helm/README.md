# Terraform AWS Module: 1-nbs7/aws-prometheus-grafana/prometheus-helm

## Description

This module is used to deploy and configure the Prometheus Helm chart and related resources for NBS7.

## Module Details

<!-- BEGIN_TF_DOCS -->


### Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |

### Resources

| Name | Type |
| ---- | ---- |
| [helm_release.prometheus](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_chart"></a> [chart](#input\_chart) | The name of the Helm chart | `string` | n/a | yes |
| <a name="input_dependency_update"></a> [dependency\_update](#input\_dependency\_update) | Set to true to update the Helm chart dependencies before install | `bool` | n/a | yes |
| <a name="input_force_update"></a> [force\_update](#input\_force\_update) | Set to true to force resource updates through a replace operation | `bool` | n/a | yes |
| <a name="input_iam_proxy_prometheus_role_arn"></a> [iam\_proxy\_prometheus\_role\_arn](#input\_iam\_proxy\_prometheus\_role\_arn) | The ARN of the IAM role used by the Prometheus proxy | `string` | n/a | yes |
| <a name="input_lint"></a> [lint](#input\_lint) | Set to true to lint the Helm chart before install | `bool` | n/a | yes |
| <a name="input_namespace_name"></a> [namespace\_name](#input\_namespace\_name) | The name of the Kubernetes namespace | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The AWS region to use for the resources | `string` | n/a | yes |
| <a name="input_repository"></a> [repository](#input\_repository) | The URL of the Helm chart repository | `string` | n/a | yes |
| <a name="input_service_account_amp_ingest_name"></a> [service\_account\_amp\_ingest\_name](#input\_service\_account\_amp\_ingest\_name) | The name of the service account used to ingest data into Amazon Managed Prometheus | `string` | n/a | yes |
| <a name="input_workspace_id"></a> [workspace\_id](#input\_workspace\_id) | The ID of the Amazon Managed Prometheus workspace | `string` | n/a | yes |
<!-- END_TF_DOCS -->
