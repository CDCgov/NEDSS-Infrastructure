# Terraform AWS Module: 1-nbs7/aws-prometheus-grafana

## Description

This module is used to deploy and configure AWS Managed Service for Grafana, AWS Managed Service for Prometheus and related resources for NBS7.

## Module Details

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.15.6 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | >= 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.21.0, < 7.0.0 |
| <a name="requirement_grafana"></a> [grafana](#requirement\_grafana) | >= 4.19.0, < 5.0.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 3.1.1, < 4.0.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.38.0, < 3.0.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.0.0 |

### Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.21.0 |

### Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_grafana-dashboard"></a> [grafana-dashboard](#module\_grafana-dashboard) | ./modules/grafana-dashboard | n/a |
| <a name="module_grafana-token-rotation"></a> [grafana-token-rotation](#module\_grafana-token-rotation) | ./modules/grafana-token-rotation | n/a |
| <a name="module_grafana-workspace"></a> [grafana-workspace](#module\_grafana-workspace) | ./modules/grafana-workspace | n/a |
| <a name="module_iam-role"></a> [iam-role](#module\_iam-role) | ./modules/iam-roles | n/a |
| <a name="module_prometheus-helm"></a> [prometheus-helm](#module\_prometheus-helm) | ./modules/prometheus-helm | n/a |
| <a name="module_prometheus-workspace"></a> [prometheus-workspace](#module\_prometheus-workspace) | ./modules/prometheus-workspace | n/a |

### Resources

| Name | Type |
| ---- | ---- |
| [aws_lambda_invocation.initial_token_rotation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_invocation) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_secretsmanager_secret_version.grafana_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#input\_cluster\_certificate\_authority\_data) | The base64-encoded certificate data needed to talk to the cluster | `string` | n/a | yes |
| <a name="input_eks_aws_role_arn"></a> [eks\_aws\_role\_arn](#input\_eks\_aws\_role\_arn) | The IAM role ARN of the EKS cluster | `string` | n/a | yes |
| <a name="input_eks_cluster_endpoint"></a> [eks\_cluster\_endpoint](#input\_eks\_cluster\_endpoint) | The endpoint of the EKS cluster | `string` | n/a | yes |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | The name of the EKS cluster | `string` | n/a | yes |
| <a name="input_oidc_provider_arn"></a> [oidc\_provider\_arn](#input\_oidc\_provider\_arn) | The ARN of the OIDC provider | `string` | n/a | yes |
| <a name="input_oidc_provider_url"></a> [oidc\_provider\_url](#input\_oidc\_provider\_url) | The URL of the OIDC provider | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to the resources | `map(string)` | n/a | yes |
| <a name="input_chart"></a> [chart](#input\_chart) | The name of the Prometheus Helm chart | `string` | `"prometheus"` | no |
| <a name="input_data_sources"></a> [data\_sources](#input\_data\_sources) | The list of Grafana data sources | `list(any)` | <pre>[<br/>  "PROMETHEUS"<br/>]</pre> | no |
| <a name="input_dependency_update"></a> [dependency\_update](#input\_dependency\_update) | Set to true to update the Helm chart dependencies before install | `bool` | `true` | no |
| <a name="input_force_update"></a> [force\_update](#input\_force\_update) | Set to true to force resource updates through a replace operation | `bool` | `true` | no |
| <a name="input_lint"></a> [lint](#input\_lint) | Set to true to lint the Helm chart before install | `bool` | `true` | no |
| <a name="input_namespace_name"></a> [namespace\_name](#input\_namespace\_name) | The name of the Kubernetes namespace | `string` | `"observability"` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region to use for the resources | `string` | `"us-east-1"` | no |
| <a name="input_repository"></a> [repository](#input\_repository) | The URL of the Prometheus Helm chart repository | `string` | `"https://prometheus-community.github.io/helm-charts/"` | no |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix for resource names | `string` | `"cdc-nbs"` | no |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | The number of days to keep the log data | `number` | `30` | no |

### Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_amg-workspace-id"></a> [amg-workspace-id](#output\_amg-workspace-id) | The ID of the Grafana workspace |
| <a name="output_amg-workspace_endpoint"></a> [amg-workspace\_endpoint](#output\_amg-workspace\_endpoint) | The endpoint of the Grafana workspace |
| <a name="output_amp_workspace_endpoint"></a> [amp\_workspace\_endpoint](#output\_amp\_workspace\_endpoint) | The endpoint of the Prometheus workspace |
| <a name="output_amp_workspace_id"></a> [amp\_workspace\_id](#output\_amp\_workspace\_id) | The ID of the Prometheus workspace |
| <a name="output_grafana-token-rotation-lambda"></a> [grafana-token-rotation-lambda](#output\_grafana-token-rotation-lambda) | Name of the Lambda function that rotates the Grafana token |
| <a name="output_grafana-token-secret-arn"></a> [grafana-token-secret-arn](#output\_grafana-token-secret-arn) | ARN of the Secrets Manager secret containing the Grafana token |
| <a name="output_grafana-token-secret-name"></a> [grafana-token-secret-name](#output\_grafana-token-secret-name) | Name of the Secrets Manager secret containing the Grafana token |
| <a name="output_prometheus_role_arn"></a> [prometheus\_role\_arn](#output\_prometheus\_role\_arn) | The ARN of the Prometheus IAM role |
| <a name="output_sns_topic_arn"></a> [sns\_topic\_arn](#output\_sns\_topic\_arn) | The ARN of the SNS topic for Prometheus alerts |
<!-- END_TF_DOCS -->
