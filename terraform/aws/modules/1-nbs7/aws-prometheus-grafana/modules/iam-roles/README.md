# Terraform AWS Module: 1-nbs7/aws-prometheus-grafana/iam-roles

## Description

This module deploys and configures Prometheus/Grafana-related IAM roles for NBS7.

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

| Name                                                                                                                                             | Type     |
| ------------------------------------------------------------------------------------------------------------------------------------------------ | -------- |
| [aws_iam_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                  | resource |
| [aws_iam_policy_attachment.prometheus-attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_role.prometheus_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                             | resource |

### Inputs

| Name                                                                                                                           | Description                                                                        | Type          | Default | Required |
| ------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------- | ------------- | ------- | :------: |
| <a name="input_oidc_provider"></a> [oidc_provider](#input_oidc_provider)                                                       | The OIDC provider for the EKS cluster                                              | `string`      | n/a     |   yes    |
| <a name="input_oidc_provider_arn"></a> [oidc_provider_arn](#input_oidc_provider_arn)                                           | The ARN of the OIDC provider for the EKS cluster                                   | `string`      | n/a     |   yes    |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix)                                                 | The prefix text to add to the start of each resource name                          | `string`      | n/a     |   yes    |
| <a name="input_service_account_amp_ingest_name"></a> [service_account_amp_ingest_name](#input_service_account_amp_ingest_name) | The name of the service account used to ingest data into Amazon Managed Prometheus | `string`      | n/a     |   yes    |
| <a name="input_service_account_namespace"></a> [service_account_namespace](#input_service_account_namespace)                   | The Kubernetes namespace of the service account                                    | `string`      | n/a     |   yes    |
| <a name="input_tags"></a> [tags](#input_tags)                                                                                  | A map of tags to add to the resources                                              | `map(string)` | n/a     |   yes    |

### Outputs

| Name                                                                                         | Description |
| -------------------------------------------------------------------------------------------- | ----------- |
| <a name="output_prometheus_role_arn"></a> [prometheus_role_arn](#output_prometheus_role_arn) | n/a         |

<!-- END_TF_DOCS -->
