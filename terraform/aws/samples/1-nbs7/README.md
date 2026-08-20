# Terraform Module Layer: 1-nbs7

## Description

This Terraform module layer provisions infrastructure required to run nbs7 and **expects certain upstream infrastructure
to already exist** (VPCs, subnets, IAM roles etc.). This README explains **how those dependencies are referenced**.

## 🧭 Purpose & Scope

This module:

- **Creates foundational NBS7 infrastructure**
- **Consumes upstream resources via data sources or inputs**

Typical usage:

- 0-landing-zone → **1-nbs7 \(this module)** → 2-applications
- Environment-specific deployments (dev / stage / prod)

## 💻 System Prerequisites

- Terraform >= 1.15.6
- AWS CLI configured
- Access to required AWS accounts
- Network connection if Kuberentes cluster is has its API endpoint set to private

## 🔗 Upstream Dependencies

<details>
<summary><strong> Networking Dependencies</strong></summary>

Networking including VPCs and public hosted zones **must already exist** and are referenced as described below. While nbs6 components are expected to exist
in order for NBS7 microservices to be deployed successfully, the 1-nbs7 infrastructure **does not** directly depend on functional NBS6 services. Exceptions to
this include modifying security groups to allow operations involving the database.

</details>

## Module Details

<!-- BEGIN_TF_DOCS -->

### Requirements

| Name                                                                     | Version            |
| ------------------------------------------------------------------------ | ------------------ |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.15.6          |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | >= 6.21.0, < 7.0.0 |
| <a name="requirement_helm"></a> [helm](#requirement_helm)                | >= 3.1.1, < 4.0.0  |

### Providers

| Name                                             | Version            |
| ------------------------------------------------ | ------------------ |
| <a name="provider_aws"></a> [aws](#provider_aws) | >= 6.21.0, < 7.0.0 |

### Modules

| Name                                                                          | Source                                 | Version |
| ----------------------------------------------------------------------------- | -------------------------------------- | ------- |
| <a name="module_efs"></a> [efs](#module_efs)                                  | ../../modules/1-nbs7/efs               | n/a     |
| <a name="module_eks_nbs"></a> [eks_nbs](#module_eks_nbs)                      | ../../modules/1-nbs7/eks-nbs           | n/a     |
| <a name="module_kms"></a> [kms](#module_kms)                                  | ../../modules/1-nbs7/kms               | n/a     |
| <a name="module_msk"></a> [msk](#module_msk)                                  | ../../modules/1-nbs7/msk               | n/a     |
| <a name="module_s3_datacompare"></a> [s3_datacompare](#module_s3_datacompare) | ../../modules/1-nbs7/s3-bucket         | n/a     |
| <a name="module_s3_otel_logs"></a> [s3_otel_logs](#module_s3_otel_logs)       | ../../modules/1-nbs7/s3-bucket         | n/a     |
| <a name="module_vpc-endpoints"></a> [vpc-endpoints](#module_vpc-endpoints)    | ../../modules/1-nbs7/vpc-endpoints-nbs | n/a     |

### Resources

| Name                                                                                                                 | Type        |
| -------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)          | data source |
| [aws_route53_zone.root](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_subnet.nbs7](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet)             | data source |
| [aws_subnets.nbs7](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets)           | data source |
| [aws_vpc.nbs7](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc)                   | data source |

### Inputs

| Name                                                                                                                              | Description                                                                                                                                                                                                   | Type                                                     | Default      | Required |
| --------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------- | ------------ | :------: |
| <a name="input_aws_role_arn"></a> [aws_role_arn](#input_aws_role_arn)                                                             | AWS IAM Role/USEr arn used to authenticate into the EKS cluster                                                                                                                                               | `string`                                                 | n/a          |   yes    |
| <a name="input_domain_name"></a> [domain_name](#input_domain_name)                                                                | Domain name associated with an AWS public hosted zone in current account? (e.g. nbspreview.com)                                                                                                               | `string`                                                 | n/a          |   yes    |
| <a name="input_eks_allow_endpoint_public_access"></a> [eks_allow_endpoint_public_access](#input_eks_allow_endpoint_public_access) | Allow both public and private access to EKS api endpoint. If False, terraform must have access to AWS network containing EKS API.                                                                             | `bool`                                                   | n/a          |   yes    |
| <a name="input_kms_key_administrators"></a> [kms_key_administrators](#input_kms_key_administrators)                               | A list of IAM ARNs for key administrators. If no value is provided, the current caller identity is used to ensure at least one key admin is available.                                                        | `list(string)`                                           | n/a          |   yes    |
| <a name="input_msk_environment"></a> [msk_environment](#input_msk_environment)                                                    | The environment, either 'development' which provisions 2 brokers in 2 different subnets or 'production' which provisions 3 brokers in 3 different subnets.                                                    | `string`                                                 | n/a          |   yes    |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix)                                                    | Prefix for resource names                                                                                                                                                                                     | `string`                                                 | n/a          |   yes    |
| <a name="input_tags"></a> [tags](#input_tags)                                                                                     | Map(string) of tags to add to created resources                                                                                                                                                               | `map(string)`                                            | n/a          |   yes    |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id)                                                                               | VPC ID of virtual private cloud                                                                                                                                                                               | `string`                                                 | n/a          |   yes    |
| <a name="input_admin_role_arns"></a> [admin_role_arns](#input_admin_role_arns)                                                    | List of AWS IAM Role ARNs for admin access to the EKS cluster. If not provided, aws_role_arn will be used.                                                                                                    | `list(string)`                                           | `[]`         |    no    |
| <a name="input_create_datacompare_resources"></a> [create_datacompare_resources](#input_create_datacompare_resources)             | Create resources for DataCompare service?                                                                                                                                                                     | `bool`                                                   | `false`      |    no    |
| <a name="input_create_grafana_vpc_endpoint"></a> [create_grafana_vpc_endpoint](#input_create_grafana_vpc_endpoint)                | Create Grafana VPC endpoint and security group?                                                                                                                                                               | `bool`                                                   | `true`       |    no    |
| <a name="input_create_otel_collector_resources"></a> [create_otel_collector_resources](#input_create_otel_collector_resources)    | Create resources for OTEL Collector log export?                                                                                                                                                               | `bool`                                                   | `false`      |    no    |
| <a name="input_create_prometheus_vpc_endpoint"></a> [create_prometheus_vpc_endpoint](#input_create_prometheus_vpc_endpoint)       | Create Prometheus VPC endpoint and security group?                                                                                                                                                            | `bool`                                                   | `true`       |    no    |
| <a name="input_deploy_argocd_helm"></a> [deploy_argocd_helm](#input_deploy_argocd_helm)                                           | Do you wish to deploy ArgoCD with the EKS cluster deployment?                                                                                                                                                 | `string`                                                 | `"false"`    |    no    |
| <a name="input_efs_mount_targets"></a> [efs_mount_targets](#input_efs_mount_targets)                                              | Optional override to EFS mount targets. If used must match provided efs_vpc_cidrs. Sample input below.                                                                                                        | <pre>map(object({<br/> subnet_id = string<br/> }))</pre> | `null`       |    no    |
| <a name="input_efs_subnet_cidrs"></a> [efs_subnet_cidrs](#input_efs_subnet_cidrs)                                                 | Optional override to EFS VPC subnet CIDR blocks. If used must match efs_mount_targets provided subnets.                                                                                                       | `list(string)`                                           | `null`       |    no    |
| <a name="input_eks_desired_nodes_count"></a> [eks_desired_nodes_count](#input_eks_desired_nodes_count)                            | Number of EKS nodes desired                                                                                                                                                                                   | `number`                                                 | `3`          |    no    |
| <a name="input_eks_disk_size"></a> [eks_disk_size](#input_eks_disk_size)                                                          | Size of EKS volumes in GB                                                                                                                                                                                     | `number`                                                 | `100`        |    no    |
| <a name="input_eks_instance_type"></a> [eks_instance_type](#input_eks_instance_type)                                              | Instance type to use in EKS cluster                                                                                                                                                                           | `string`                                                 | `"m5.large"` |    no    |
| <a name="input_eks_max_nodes_count"></a> [eks_max_nodes_count](#input_eks_max_nodes_count)                                        | Maximum number of EKS nodes                                                                                                                                                                                   | `number`                                                 | `5`          |    no    |
| <a name="input_eks_min_nodes_count"></a> [eks_min_nodes_count](#input_eks_min_nodes_count)                                        | Minimum umber of EKS nodes                                                                                                                                                                                    | `number`                                                 | `3`          |    no    |
| <a name="input_eks_subnets"></a> [eks_subnets](#input_eks_subnets)                                                                | Override to use a desired subnets, default = use available subnets                                                                                                                                            | `list(string)`                                           | `null`       |    no    |
| <a name="input_endpoint_private_subnet_ids"></a> [endpoint_private_subnet_ids](#input_endpoint_private_subnet_ids)                | Optional override for subnets provided to create interface endpoints. Note within the same VPC, each subnet must be within a unique availability zone.                                                        | `list(string)`                                           | `null`       |    no    |
| <a name="input_endpoint_vpc_cidr_block"></a> [endpoint_vpc_cidr_block](#input_endpoint_vpc_cidr_block)                            | Optional override for vpc cidr block provided to create interface endpoints.                                                                                                                                  | `string`                                                 | `null`       |    no    |
| <a name="input_external_cidr_blocks"></a> [external_cidr_blocks](#input_external_cidr_blocks)                                     | List of cidr blocks to add to security groups, e.g. vpn, admin                                                                                                                                                | `list(string)`                                           | `[]`         |    no    |
| <a name="input_kubernetes_addons"></a> [kubernetes_addons](#input_kubernetes_addons)                                              | Map of cluster addon configurations to enable for the cluster                                                                                                                                                 | `map(any)`                                               | `null`       |    no    |
| <a name="input_kubernetes_ami_release_version"></a> [kubernetes_ami_release_version](#input_kubernetes_ami_release_version)       | AMI version of the EKS Node Group                                                                                                                                                                             | `string`                                                 | `null`       |    no    |
| <a name="input_kubernetes_version_control_plane"></a> [kubernetes_version_control_plane](#input_kubernetes_version_control_plane) | Desired Kubernetes version for control plane in EKS cluster                                                                                                                                                   | `string`                                                 | `null`       |    no    |
| <a name="input_kubernetes_version_node_group"></a> [kubernetes_version_node_group](#input_kubernetes_version_node_group)          | Kubernetes version for node group in EKS cluster                                                                                                                                                              | `string`                                                 | `null`       |    no    |
| <a name="input_msk_ebs_volume_size"></a> [msk_ebs_volume_size](#input_msk_ebs_volume_size)                                        | EBS volume size for the MSK broker nodes in GB                                                                                                                                                                | `number`                                                 | `100`        |    no    |
| <a name="input_msk_subnets"></a> [msk_subnets](#input_msk_subnets)                                                                | Override to use a desired subnets for MSK, default = use available subnets. NOTE: msk_environment ='development' requires 2 different subnets and msk_environment = 'production'requires 3 different subnets. | `list(string)`                                           | `null`       |    no    |
| <a name="input_readonly_role_arn"></a> [readonly_role_arn](#input_readonly_role_arn)                                              | Optional AWS IAM Role arn used to authenticate into the EKS cluster for ReadOnly                                                                                                                              | `string`                                                 | `null`       |    no    |
| <a name="input_readonly_role_arns"></a> [readonly_role_arns](#input_readonly_role_arns)                                           | List of AWS IAM Role ARNs for readonly access to the EKS cluster. If not provided, readonly_role_arn will be used if set.                                                                                     | `list(string)`                                           | `[]`         |    no    |

<!-- END_TF_DOCS -->
