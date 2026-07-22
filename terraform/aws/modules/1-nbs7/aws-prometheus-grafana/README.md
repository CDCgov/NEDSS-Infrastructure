# Deploying AWS Resource with Terraform

## Description

Contained within are modules for deploying baseline resources within a respoective AWS environment using Terraform. The below module is used for deployment of AWS Grafana, AWS Prometheus and purposes.

## Values

Below are the available Variables contained within this aws-prometheus-grafana module.

| Key | Type | Default | Description |
| -------------- | -------------- | -------------- | -------------- |
| alias | string | "cdc-nbs-prometheus-metrics" | Alias for prometheus workspace |
| chart | string | "prometheus" | Prometheus helm chart name |
| cluster_certificate_authority_data | string |  | TBase64 encoded certificate data required to communicate with the cluster |
| data_sources | list(any) | ["PROMETHEUS"] | The datasource for AWS Grafana; in this case Prometheus |
| dependency_update | boolean | true | Updates all dependencies for Prometheus helm chart |
| eks_aws_role_arn | string |  | IAM role ARN of the EKS cluster |
| eks_cluster_endpoint | string |  | The endpoint of the EKS cluster |
| eks_cluster_name | string |  | Name of the EKS cluster |
| force_update | boolean | true | Force update in new deployments |
| grafana_endpoint | string | "grafana_vpc_endpoint" | VPC endpoint name for AWS Grafana |
| grafana_sg_name | string |  | AWS grafana vpc endpoint security group name |
| grafana_workspace_name | string | "cdc-nbs-grafana-metrics" | The AWS Grafana workspace name |
| lint | boolean | true | Lints the Prometheus helm chart |
| namespace_name | string | "observability" | Namespace name |
| oidc_provider_arn | string |  | The ARN of the OIDC provider |
| oidc_provider_url | string |  | The URL of the OIDC provider |
| private_subnet_ids | list |  | List subnets for the prometheus workspace |
| prometheus_endpoint | string | "prometheus_vpc_endpoint" | VPC endpoint name for AWS Prometheus |
| prometheus_sg_name | string | "amp_vpc_endpoint_sg" | AWS prometheus vpc endpoint security group name |
| region | string | "us-east-1" | AWS Region |
| repository | string | "https://prometheus-community.github.io/helm-charts/" | Prometheus remote repository location |
| resource_prefix | string | "cdc-nbs" | Prefix for resource names |
| retention_in_days | number | 30 | Number of days to retain logs |
| service_account_namespace | string | "observability" | Service account namespace name |
| tags | map(string) |  | The tags added to the resources |
| values_file_path | string | "../modules/aws-prometheus-grafana/modules/prometheus-helm/values.yaml" | Path to the values.yaml file |

Below are the available Outputs contained within this DNS moudle:

| Key | Type | Default | Description |
| -------------- | -------------- | -------------- | -------------- |
| amg-workspace_endpoint |  | `grafana-workspace.amg-workspace_endpoint` | AWS Grafana workspace endpoint |
| amg-workspace-api-key |  | `module.grafana-workspace.amg-workspace-api-key` | AWS Grafana workspace api key |
| amp_workspace_endpoint |  | `module.prometheus-workspace.amp_workspace_endpoint` | AWS Prometheus workspace endpoint |
| amp_workspace_id |  | `module.prometheus-workspace.amp_workspace_id` | AWS Prometheus workspace ID |
| prometheus_role_arn |  | `module.iam-role.prometheus_role_arn` | AWS Prometheus Role ARN |
| sns_topic_arn |  | `module.prometheus-workspace.sns_topic_arn` | The ARN of the SNS topic |

