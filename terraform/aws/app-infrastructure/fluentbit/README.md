# Terraform Deployment of AWS Elastic Kubernetes Server (EKS)

## Description

This module is used to deploy and configure Fluentbit. 


## Inputs

Below are the input parameter variables for Fluentbit:

| Key | Type | Default | Description |
| -------------- | -------------- | -------------- | -------------- |
| bucket_name | string | `cdc-nbs-fluentbit-logs` | Name of bucket to forward logs to |
| chart | string | `fluent-bit` | Fluentbit chart name |
| cluster_certificate_authority_data | string |  | TBase64 encoded certificate data required to communicate with the cluster |
| eks_aws_role_arn | string |  | IAM role ARN of the EKS cluster |
| eks_cluster_endpoint | string |  | The endpoint of the EKS cluster |
| eks_cluster_name | string |  | Name of the EKS cluster |
| log_group_name | string | `fluent-bit-cloudwatch` | The name of CloudWatch log group |
| namespace_name | string |  | The namespace for service account for fluentbit (typically observability) |
| OIDC_PROVIDER_ARN | string |  | The ARN of the OIDC provider  |
| OIDC_PROVIDER_URL | string |  | The URL of the OIDC provider |
| path_to_fluentbit | string | `../modules/fluentbit` | Path to the fluentbit module (No trailing slash needed) |
| release_name | string | `fluentbit` | The of the helm release |
| repository | string | `https://fluent.github.io/helm-charts/` | The fluentbit repo name |
| SERVICE_ACCOUNT_NAME | string | `fluentbit-service-account` | The name of the service account for fluentbit |
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


