# Terraform Deployment of AWS Elastic Kubernetes Server (EKS)

## Description

This module is used to deploy and configure an AWS Elastic Kubernetes Server (EKS). Optionally, you can choose to deploy Istio (not compatible with nginx-ingress) and/or ArgoCD.

**NOTE:** Using isitio requires that the target namespace(s) has the label "istio-injection=enabled".

## Inputs

Below are the input parameter variables for the eks-nbs:

| Key | Type | Default | Description |
| -------------- | -------------- | -------------- | -------------- |
| admin_role_arns | list(string) | [] | List of AWS IAM Role ARNs for admin access to the EKS cluster. If not provided, aws_role_arn will be used. |
| allow_endpoint_public_access | bool | false | Allow both public and private access to EKS api endpoint |
| argocd_version | string | `5.23.3` | Version of ArgoCD with which to bootstrap EKS cluster |
| aws_role_arn | string |  | AWS IAM Role arn used to authenticate into the EKS cluster (legacy - use admin_role_arns for multiple roles) |
| cert_manager_hosted_zone_arns | list(string) |  | ARNs for Route 53 hosted zones that Cert Manager can access |
| cluster_version | string | `1.32` | Version of the AWS EKS cluster to provision  |
| deploy_argocd_helm | string | `false` | Do you wish to bootstrap ArgoCD with the EKS cluster deployment? |
| deploy_istio_helm | string | `false` | Do you wish to bootstrap Istio with the EKS cluster deployment? |
| desired_nodes_count | number | `3` | Base number of EKS nodes to be maintained by the autoscaling group |
| external_cidr_blocks | list(any) | [] | List of CIDR blocks (ex. 10.0.0.0/32) to allow access to eks cluster API |
| ebs_volume_size | number | `100` | EBS volume size backing *each* EKS node on creation |
| instance_type | string | `m5.large` | The AWS EC2 instance type with which to spin up EKS nodes |
| istio_version | string | `1.17.2` | Version of Istio with which to bootstrap EKS cluster |
| kms_key_administrators | list(any) | [] | A list of IAM ARNs for key administrators. If no value is provided, the current caller identity is used to ensure at least one key admin is available |
| kms_key_enable_default_policy | bool | false | Specifies whether to enable the default key policy |
| kms_key_owners | list(any) | [] | A list of IAM ARNs for those who will have full key permissions (kms:*) |
| max_nodes_count | number | `5` | Maximum number of EKS nodes allowed by the autoscaling group |
| min_nodes_count | number | `3` | Minimum number of EKS nodes allowed by the autoscaling group |
| name | string | `` | Name of the EKS cluster (an overwrite option to use a custom name) |
| readonly_role_arn | string | `null` | Optional AWS IAM Role arn for readonly access to the EKS cluster (legacy - use readonly_role_arns for multiple roles) |
| readonly_role_arns | list(string) | [] | List of AWS IAM Role ARNs for readonly access to the EKS cluster. If not provided, readonly_role_arn will be used if set. |
| resource_prefix | string | `cdc-nbs` | Prefix for resource names |
| subnets | list(string) | | List of the AWS private subnets ids associated with the supplied vpc_id to deploy in which to deploy the cluster |
| use_ecr_pull_through_cache | bool | false | Create and use ECR pull through caching for bootstrapped helm charts |
| vpc_id | string | | The AWS VPC ID to deploy in which to deploy the cluster |

## Outputs

Below are the referenceable outputs from this module.

| Key | Description |
| -------------- | -------------- |
| admin_role_arns | List of IAM role ARNs with admin access to the cluster |
| cluster_certificate_authority_data | TBase64 encoded certificate data required to communicate with the cluster  |
| cluster_oidc_issuer_url | The URL on the EKS cluster for the OpenID Connect identity provider  |
| eks_aws_role_arn | AWS IAM role ARN of the EKS cluster  |
| eks_cluster_endpoint | Endpoint for your Kubernetes API server  |
| eks_cluster_name | The name provided to the EKS cluster  |
| oidc_provider_arn | The ARN of the OIDC Provider if enable_irsa = true  |
| readonly_role_arns | List of IAM role ARNs with readonly access to the cluster |

## Module Dependencies

Dependencies are external modules that this module references. A module is considered external if it isn't within the same repository.

- eks_nbs (19.15.3): `terraform-aws-modules/eks/aws`
- efs_cni_irsa_role: `terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts`
