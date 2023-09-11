# Terraform Deployment of AWS Elastic Kubernetes Server (EKS)

## Description

This module is used to deploy and configure an AWS Elastic Kubernetes Server (EKS). Optionally, you can choose to deploy Istio (not compatible with nginx-ingress) and/or ArgoCD.

**NOTE:** Using isitio requires that the target namespace(s) has the label "istio-injection=enabled".

## Inputs

Below are the input parameter variables for the eks-nbs:

| Key | Type | Default | Description |
| -------------- | -------------- | -------------- | -------------- |
| argocd_version | string | `5.23.3` | Version of ArgoCD with which to bootstrap EKS cluster |
| aws_role_arn | string |  | AWS IAM Role arn used to authenticate into the EKS cluster  |
| cluster_version | string | `1.26` | Version of the AWS EKS cluster to provision  |
| deploy_argocd_helm | string | `true` | Do you wish to bootstrap ArgoCD with the EKS cluster deployment? |
| deploy_istio_helm | string | `false` | Do you wish to bootstrap Istio with the EKS cluster deployment? |
| desired_nodes_count | number | `5` | Base number of EKS nodes to be maintained by the autoscaling group |
| ebs_volume_size | number | `100` | EBS volume size backing *each* EKS node on creation |
| instance_type | string | `m5.large` | The AWS EC2 instance type with which to spin up EKS nodes |
| istio_version | string | `1.17.2` | Version of Istio with which to bootstrap EKS cluster |
| max_nodes_count | number | `3` | Minimum number of EKS nodes allowed by the autoscaling group |
| min_nodes_count | number | `5` | Maximum number of EKS nodes allowed by the autoscaling group |
| name | string | `cdc-nbs-sandbox` | Name of the EKS cluster |
| observability_namespace | map(string) | `null` | Labels to add to observability namespace  |
| observability_namespace | string | `observability` | Name for the observability namespace with the EKS cluster to be created  |
| sso_role_arn | string |  | AWS SSO IAM Role arn used to authenticate into the EKS cluster  |
| subnets | list(string) | | List of the AWS private subnets ids associated with the supplied vpc_id to deploy in which to deploy the cluster |
| vpc_id | string | | The AWS VPC ID to deploy in which to deploy the cluster |

## Outputs

Below are the referenceable outputs from this module.

| Key | Description |
| -------------- | -------------- |
| cluster_certificate_authority_data | TBase64 encoded certificate data required to communicate with the cluster  |
| cluster_oidc_issuer_url | The URL on the EKS cluster for the OpenID Connect identity provider  |
| eks_aws_role_arn | AWS IAM role ARN of the EKS cluster  |
| eks_cluster_endpoint | Endpoint for your Kubernetes API server  |
| eks_cluster_name | The name provided to the EKS cluster  |
| oidc_provider_arn | The ARN of the OIDC Provider if enable_irsa = true  |
| precreated_observability_namespace_name | Name of the observability namespace  |

## Module Dependencies 

Dependencies are external modules that this module references. A module is considered external if it isn't within the same repository.

- eks_nbs (19.15.3): `terraform-aws-modules/eks/aws`
- efs_cni_irsa_role: `terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks`

