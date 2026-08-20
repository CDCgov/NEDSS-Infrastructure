# Terraform AWS Module: 1-nbs7/aws-prometheus-grafana/iam-roles

## Description

This module is used to deploy and configure Prometheus/Grafana-related IAM roles for NBS7.

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
| [aws_iam_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_attachment.prometheus-attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_role.prometheus_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_oidc_provider"></a> [oidc\_provider](#input\_oidc\_provider) | The OIDC provider for the EKS cluster | `string` | n/a | yes |
| <a name="input_oidc_provider_arn"></a> [oidc\_provider\_arn](#input\_oidc\_provider\_arn) | The ARN of the OIDC provider for the EKS cluster | `string` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | The prefix text to add to the start of each resource name | `string` | n/a | yes |
| <a name="input_service_account_amp_ingest_name"></a> [service\_account\_amp\_ingest\_name](#input\_service\_account\_amp\_ingest\_name) | The name of the service account used to ingest data into Amazon Managed Prometheus | `string` | n/a | yes |
| <a name="input_service_account_namespace"></a> [service\_account\_namespace](#input\_service\_account\_namespace) | The Kubernetes namespace of the service account | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to the resources | `map(string)` | n/a | yes |

### Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_prometheus_role_arn"></a> [prometheus\_role\_arn](#output\_prometheus\_role\_arn) | n/a |
<!-- END_TF_DOCS -->
