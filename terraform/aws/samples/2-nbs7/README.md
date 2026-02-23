# Terraform Module: 2-nbs7

This Terraform module layer provisions infrastructure required to run nbs7 and **expects certain upstream infrastructure
to already exist** (VPCs, subnets, IAM roles etc.). This README explains **how those dependencies are referenced**.

## 🧭 Purpose & Scope

This module:
- **Creates foundational NBS7 infrastructure**
- **Consumes upstream resources via data sources or inputs**

Typical usage:
- 0-landing-zone → 1-nbs6 → **2-nbs7 \(this module)** → 3-applications 
- Environment-specific deployments (dev / stage / prod)

## 💻 System Prerequisites
- Terraform >= 1.11.0 # if using state locking (>=1.5.7 otherwise)
- AWS CLI configured
- Access to required AWS accounts
- Network connection if Kuberentes cluster is has its API endpoint set to private

## 🔗 Upstream Dependencies 

<details>
<summary><strong> Networking Dependencies</strong></summary>

Networking including VPCs and public hosted zones **must already exist** and are referenced as described below. While 1-nbs6 components are expected to exist
in order for NBS7 microservices to be deployed successfully, the 2-nbs7 infrastructure **does not** directly depend on functional NBS6 services. Exceptions to 
this include modifying security groups to allow operations involving the database.

| Resource | Description | How It’s Referenced |
|--------|-------------|---------------------|
| vpc_id | VPC ID of virtual private cloud. | `data.aws_vpc` |
| domain_name | Domain name associated with an AWS public hosted zone in current account? (e.g. nbspreview.com) | `data.aws_route53_zone` |


</details>

##  🚀 Installation

<details>
<summary><strong>Modules </strong></summary>

- Elastic File System (EFS)
- Elastic Kubernetes Service (EKS)
    - IAM roles
    - Helm charts for bootstrapping the cluster
    - KMS Key
    - Kubernetes Cluster (plus addons)
    - Autoscaling Group
    - Security Groups
- Managed Streaming for Apache Kafka (MSK)
- Managed Prometheus and Grafana
- VPC endpoints for Prometheus and Grafana

</details>

<details>
<summary><strong>Required input varaibles (terraform.tfvars) </strong></summary>

| Parameter | Description | Default
|--------|-------------|---------------------|
| resource_prefix | Prefix for resource names | |
| tags | Map(string) of tags to add to created resources | |
| domain_name | Domain name associated with an AWS public hosted zone in current account? (e.g. nbspreview.com) |  |
| vpc_id | VPC ID of virtual private cloud |  |
| aws_role_arn | AWS IAM Role/USEr arn used to authenticate into the EKS cluster" |  |
| readonly_role_arn | Optional AWS IAM Role arn used to authenticate into the EKS cluster for ReadOnly | null |
| admin_role_arns | List of AWS IAM Role ARNs for admin access to the EKS cluster. If not provided, aws_role_arn will be used. | `[]` |
| readonly_role_arns | List of AWS IAM Role ARNs for readonly access to the EKS cluster. If not provided, readonly_role_arn will be used if set. | `[]` |
| kms_key_administrators | A list of IAM ARNs for key administrators. If no value is provided, the current caller identity is used to ensure at least one key admin is available. |  |
| eks_allow_endpoint_public_access | Allow both public and private access to EKS api endpoint. If False, terraform must have access to AWS network containing EKS API. | `true` |
| msk_environment | The environment, either 'development' which provisions 2 brokers in 2 different subnets or 'production' which provisions 3 brokers in 3 different subnets. |  |

</details>

<details>
<summary><strong> All input variables (variables.tf)</strong></summary>

| Parameter | Description | Default
|--------|-------------|---------------------|
| resource_prefix | Prefix for resource names | |
| tags | Map(string) of tags to add to created resources | |
| domain_name | Domain name associated with an AWS public hosted zone in current account? (e.g. nbspreview.com) |  |
| vpc_id | VPC ID of virtual private cloud |  |
| aws_role_arn | AWS IAM Role/USEr arn used to authenticate into the EKS cluster" |  |
| readonly_role_arn | Optional AWS IAM Role arn used to authenticate into the EKS cluster for ReadOnly | `null` |
| admin_role_arns | List of AWS IAM Role ARNs for admin access to the EKS cluster. If not provided, aws_role_arn will be used. | `[]` |
| readonly_role_arns | List of AWS IAM Role ARNs for readonly access to the EKS cluster. If not provided, readonly_role_arn will be used if set. | `[]` |
| eks_disk_size | Size of EKS volumes in GB | `100` |
| external_cidr_blocks | List of cidr blocks to add to security groups, e.g. vpn, admin | `[]` |
| eks_cluster_version | Version of eks cluster | `1.32` |
| eks_instance_type | Instance type to use in EKS cluster | `m5.large` |
| eks_desired_nodes_count | Number of EKS nodes desired | `3` |
| eks_max_nodes_count | Maximum number of EKS nodes | `5` |
| eks_min_nodes_count | Minimum umber of EKS nodes | `3` |
| deploy_argocd_helm | Do you wish to deploy ArgoCD with the EKS cluster deployment? | `"false"` |
| eks_allow_endpoint_public_access | Allow both public and private access to EKS api endpoint. If False, terraform must have access to AWS network containing EKS API. |  |
| kms_key_administrators | A list of IAM ARNs for key administrators. If no value is provided, the current caller identity is used to ensure at least one key admin is available. |  |
| eks_allow_endpoint_public_access | Allow both public and private access to EKS api endpoint. If False, terraform must have access to AWS network containing EKS API. |  |
| msk_ebs_volume_size | EBS volume size for the MSK broker nodes in GB | `100` |
| msk_environment | The environment, either 'development' which provisions 2 brokers in 2 different subnets or 'production' which provisions 3 brokers in 3 different subnets. |  |
| create_prometheus_vpc_endpoint | Create Prometheus VPC endpoint and security group? | `true` |
| create_grafana_vpc_endpoint | Create Grafana VPC endpoint and security group? | `true` |
</details>

<details>
<summary><strong>Installation</strong></summary>

## Quick Steps
```bash
# Download appropriate GitHub release from https://github.com/CDCgov/NEDSS-Infrastructure/releases
unzip <nbs-infrastructure-v<VERSION>.zip # replace version with your downloaded version
cd terraform/aws/samples/2-nbs7
terraform init
terraform plan
terraform apply