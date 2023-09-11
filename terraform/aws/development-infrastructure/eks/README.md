# Deploying AWS Resource with Terraform

## Description

Contained within are modules for deploying baseline resources within a respoective AWS environment using Terraform. The below module is used for AWS EKS purposes.

## Values

Below are the available Variables contained within this EKS module:

| Key | Type | Default | Description |
| -------------- | -------------- | -------------- | -------------- |
| argocd_imageupdater_version | string | `map(string)` | Version of ArgoCDImageUpdater with which to bootstrap EKS cluster |
| argocd_version | string | `5.23.3` | Version of ArgoCD with which to bootstrap EKS cluster |
| argo_repo_login_data | map(string) |  | Pass stringData to set up argocd connection with repo see <https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/> |
| aws_role_arn | string |  | AWS Role arn used to authenticate into EKS cluster |
| bootstrap_extra_args | string | " " | Extra args to pass to the EKS bootstrap |
| cluster_service_ipv4_cider | string | " " | An optional cluster service IPv4 CIDR |
| ebs_delete_volume_on_termination | boolean | `true` | Delete EBS volume on termination |
| ebs_encrypted | boolean | `true` | Encrypt EBS volume on creation |
| ebs_volume_size | number | `100` | EBS volume size on creation |
| ebs_volume_type | string | `gp3` | EBS volume typ eon creation |
| eks_cluster_version | string | `1.24` | Version of EKS cluster to provision |
| eks_desired_nodes_count | number | `2` | Number of EKS nodes desired (defaul = 2)
| eks_disk_size | number | `20` | Size of EKS volumes in GB |
| eks_instance_types | list(any) | `m5.large` | Instance type to use in EKS cluster |
| eks_max_nodes_count | number | `5` | Maximum number of EKS nodes (defaul =5) |
| eks_min_nodes_count | number | `1` | Number of EKS nodes desired (defaul = 1) |
| enable_bootstrap_user_data | bool | `false` | Enable bootstrap user data |
| post_bootstrap_user_data | string | " " | User data to be executed after the EKS bootstrap |
| pre_bootstrap_user_data | string | " " | User data to be executed before the EKS bootstrap |
| resource_prefix | string |  | Name to be used on all the resources as identifier. e.g. Project name, Application name |
| subnet_ids | list(any) |  | Subnet Ids to be used when creating EKS cluster |
| tags | map(string) |  | map(string) of tags to add to created hosted zone |
| vpc_id | string |  | VPC Id to be used with cluster |
