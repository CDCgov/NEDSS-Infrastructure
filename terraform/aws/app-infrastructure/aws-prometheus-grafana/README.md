# Deploying AWS Resource with Terraform

## Description

Contained within are modules for deploying baseline resources within a respoective AWS environment using Terraform. The below module is used for deployment of AWS Grafana, AWS Prometheus and purposes.

## Values

Below are the available Variables contained within this aws-prometheus-grafana module.

| Key | Type | Default | Description |
| -------------- | -------------- | -------------- | -------------- |
| vpc_id | string |  | List of VPC to which AWS Grafana and AWS Prometheus VPC endpoints are added |
| vpc_cidr_block | string |  | CIDR block of your VPC |
| private_subnet_ids | list |  | List subnets for the prometheus workspace |
| OIDC_PROVIDER_ARN | string |  | The ARN of the OIDC provider |
| OIDC_PROVIDER_URL | string |  | The URL of the OIDC provider |
| region | string | "us-east-1" | AWS Region |
| prometheus_sg_name | string | "amp_vpc_endpoint_sg" | AWS prometheus vpc endpoint security group name |
| namespace_name | string | "observability" | Namespace name |
| grafana_sg_name | string |  | AWS grafana vpc endpoint security group name |
| SERVICE_ACCOUNT_NAMESPACE | string | "observability" | Service account namespace name |
| repository | string | "https://prometheus-community.github.io/helm-charts/" | Prometheus remote repository location |
| chart | string | "prometheus" | Prometheus helm chart name |
| retention_in_days | number | 30 | Number of days to retain logs |
| alias | string | "cdc-nbs-prometheus-metrics" | Alias for prometheus workspace |
| values_file_path | string | "../modules/aws-prometheus-grafana/modules/prometheus-helm/values.yaml" | Path to the values.yaml file |
| prometheus_endpoint | string | "prometheus_vpc_endpoint" | VPC endpoint name for AWS Prometheus |
| grafana_endpoint | string | "grafana_vpc_endpoint" | VPC endpoint name for AWS Grafana |
| data_sources | list | ["PROMETHEUS"] | The datasource for AWS Grafana; in this case Prometheus |
| grafana_workspace_name | string | "cdc-nbs-grafana-metrics" | The AWS Grafana workspace name |
| tags | map(string) |  | The tags added to the resources |
| dependency_update | boolean | true | Updates all dependencies for Prometheus helm chart |
| lint | boolean | true | Lints the Prometheus helm chart |
| force_update | boolean | true | Force update in new deployments |
| eks_cluster_endpoint | string |  | The endpoint of the EKS cluster |
| cluster_certificate_authority_data | string |  | TBase64 encoded certificate data required to communicate with the cluster |
| eks_cluster_name | string |  | Name of the EKS cluster |
| eks_aws_role_arn | string |  | IAM role ARN of the EKS cluster |

Below are the available Outputs contained within this DNS moudle:

| Key | Type | Default | Description |
| -------------- | -------------- | -------------- | -------------- |
| amp_workspace_id |  | `module.prometheus-workspace.amp_workspace_id` | AWS Prometheus workspace ID |
| amp_workspace_endpoint |  | `module.prometheus-workspace.amp_workspace_endpoint` | AWS Prometheus workspace endpoint |
| prommetheus_role_arn |  | `module.iam-role.prommetheus_role_arn` | AWS Prometheus Role ARN |
| sns_topic_arn |  | `module.prometheus-workspace.sns_topic_arn` | The ARN of the SNS topic |
| amg-workspace_endpoint |  | `grafana-workspace.amg-workspace_endpoint` | AWS Grafana workspace endpoint |
| amg-workspace-api-key |  | `module.grafana-workspace.amg-workspace-api-key` | AWS Grafana workspace api key |

