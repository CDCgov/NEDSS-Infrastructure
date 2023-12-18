# Terraform Deployment of AWS Elastic Kubernetes Server (EKS)

## Description

This module is used to deploy and configure Fluentbit. 


## Inputs

Below are the input parameter variables for Fluentbit:

| Key | Type | Default | Description |
| -------------- | -------------- | -------------- | -------------- |
| bucket_name | string |  | Precreated (may be referenced from another module) S3 bucket into which logs are placed. |
| chart | string | `fluent-bit` | Fluentbit chart name |
| cluster_certificate_authority_data | string |  | TBase64 encoded certificate data required to communicate with the cluster |
| eks_aws_role_arn | string |  | IAM role ARN of the EKS cluster |
| eks_cluster_endpoint | string |  | The endpoint of the EKS cluster |
| eks_cluster_name | string |  | Name of the EKS cluster |
| force_destroy_log_bucket | boolean| false | "Boolean that indicates all objects (including any locked objects) should be deleted from the bucket when the bucket is destroyed so that the bucket can be destroyed without error." |
| log_group_name | string | `fluent-bit-cloudwatch` | The name of CloudWatch log group |
| namespace_name | string |  | The namespace for service account for fluentbit (typically observability) |
| oidc_provider_arn | string |  | The ARN of the OIDC provider  |
| oidc_provider_url | string |  | The URL of the OIDC provider |
| path_to_fluentbit | string | `../modules/fluentbit` | Path to the fluentbit module (No trailing slash needed) |
| release_name | string | `fluentbit` | The of the helm release |
| repository | string | `https://fluent.github.io/helm-charts/` | The fluentbit repo name |
| resource_prefix | string | "cdc-nbs" | Prefix for resource names |
| service_account_name | string | `fluentbit-service-account` | The name of the service account for fluentbit |
| tags | map(string) |  | Tags applied to all resources  |


## Outputs

Below are the referenceable outputs from this module.

| Key | Description |
| -------------- | -------------- |
| bucket_name | S3 bucket name  |
| eks_aws_role_arn | AWS IAM role ARN of the EKS cluster  |
| fluentbit_role_arn | Fluentbit role arn  |


## Module Dependencies 

Dependencies are external modules that this module references. A module is considered external if it isn't within the same repository.


