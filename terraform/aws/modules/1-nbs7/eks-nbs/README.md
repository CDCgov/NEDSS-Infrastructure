# Terraform AWS Module: 1-nbs7/eks-nbs

## Description

This module is used to deploy and configure AWS Elastic Kubernetes Service (EKS) and related resources for NBS7.

## Module Details

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.15.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.21.0, < 7.0.0 |
| <a name="requirement_cloudinit"></a> [cloudinit](#requirement\_cloudinit) | >= 2.3.7, <3.0.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 3.1.1, < 4.0.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.38.0, < 3.0.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.2.4, <4.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.13.1, < 1.0.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.1.0, <5.0.0 |

### Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.21.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 3.1.1 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.38.0 |

### Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_cert_manager_cni_irsa_role"></a> [cert\_manager\_cni\_irsa\_role](#module\_cert\_manager\_cni\_irsa\_role) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts | >=6.2.3, <7.0.0 |
| <a name="module_datacompare_irsa_role"></a> [datacompare\_irsa\_role](#module\_datacompare\_irsa\_role) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts | >=6.2.3, <7.0.0 |
| <a name="module_efs_cni_irsa_role"></a> [efs\_cni\_irsa\_role](#module\_efs\_cni\_irsa\_role) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts | >=6.2.3, <7.0.0 |
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | >=21.9.0, <22.0.0 |
| <a name="module_otel_collector_irsa_role"></a> [otel\_collector\_irsa\_role](#module\_otel\_collector\_irsa\_role) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts | >=6.2.3, <7.0.0 |

### Resources

| Name | Type |
| ---- | ---- |
| [aws_ecr_pull_through_cache_rule.ecr_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_pull_through_cache_rule) | resource |
| [aws_ecr_pull_through_cache_rule.quay](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_pull_through_cache_rule) | resource |
| [aws_iam_policy.datacompare_irsa_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.eks_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.otel_collector_irsa_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_vpc_security_group_ingress_rule.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [helm_release.argocd](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.cert_manager](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.efs](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.ingress-gateway](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.istio_base](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.istiod](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_namespace.istio_ingress](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.istio_system](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_iam_session_context.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_session_context) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_aws_role_arn"></a> [aws\_role\_arn](#input\_aws\_role\_arn) | AWS IAM Role arn used to authenticate into the EKS cluster | `string` | n/a | yes |
| <a name="input_cert_manager_hosted_zone_arns"></a> [cert\_manager\_hosted\_zone\_arns](#input\_cert\_manager\_hosted\_zone\_arns) | ARNs for Route 53 hosted zones that Cert Manager can access | `list(string)` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | List of the AWS private subnets ids associated with the supplied vpc\_id to deploy in which to deploy the cluster | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The AWS VPC ID to deploy in which to deploy the cluster | `string` | n/a | yes |
| <a name="input_addons"></a> [addons](#input\_addons) | Map of cluster addon configurations to enable for the cluster. Addon name can be the map keys or set with `name`. | <pre>map(object({<br/>    name                 = optional(string) # will fall back to map key<br/>    before_compute       = optional(bool, false)<br/>    most_recent          = optional(bool, true)<br/>    addon_version        = optional(string)<br/>    configuration_values = optional(string)<br/>    pod_identity_association = optional(list(object({<br/>      role_arn        = string<br/>      service_account = string<br/>    })))<br/>    preserve                    = optional(bool, true)<br/>    resolve_conflicts_on_create = optional(string, "OVERWRITE")<br/>    resolve_conflicts_on_update = optional(string, "OVERWRITE")<br/>    service_account_role_arn    = optional(string)<br/>    timeouts = optional(object({<br/>      create = optional(string)<br/>      update = optional(string)<br/>      delete = optional(string)<br/>    }), {})<br/>    tags = optional(map(string), {})<br/>  }))</pre> | <pre>{<br/>  "coredns": {},<br/>  "kube-proxy": {},<br/>  "vpc-cni": {<br/>    "before_compute": true<br/>  }<br/>}</pre> | no |
| <a name="input_admin_role_arns"></a> [admin\_role\_arns](#input\_admin\_role\_arns) | List of AWS IAM Role ARNs for admin access to the EKS cluster. If not provided, aws\_role\_arn will be used. | `list(string)` | `[]` | no |
| <a name="input_allow_endpoint_public_access"></a> [allow\_endpoint\_public\_access](#input\_allow\_endpoint\_public\_access) | Allow both public and private access to EKS api endpoint | `bool` | `false` | no |
| <a name="input_ami_release_version"></a> [ami\_release\_version](#input\_ami\_release\_version) | The AMI release version for the Node Group of the EKS cluster | `string` | `"1.35.4-20260423"` | no |
| <a name="input_argocd_version"></a> [argocd\_version](#input\_argocd\_version) | Version of ArgoCD with which to bootstrap EKS cluster | `string` | `"5.23.3"` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | (DEPRECATED) Version of the AWS EKS cluster to provision | `any` | `null` | no |
| <a name="input_create_datacompare_irsa"></a> [create\_datacompare\_irsa](#input\_create\_datacompare\_irsa) | Create an IAM roles for service accounts (IRSA) and IAM policy for the datacompare service? | `bool` | `false` | no |
| <a name="input_create_otel_collector_irsa"></a> [create\_otel\_collector\_irsa](#input\_create\_otel\_collector\_irsa) | Create IRSA role and IAM policy for the OTEL Collector S3 log export? | `bool` | `false` | no |
| <a name="input_datacompare_namespace_and_service"></a> [datacompare\_namespace\_and\_service](#input\_datacompare\_namespace\_and\_service) | List of Kubernetes namespace and services to be included in the datacompare IRSA trust policy (format= [namespace:serviceName]). | `list(string)` | <pre>[<br/>  "default:data-compare-api-service",<br/>  "default:data-compare-processor-service"<br/>]</pre> | no |
| <a name="input_datacompare_s3_bucket_keyname_prefix"></a> [datacompare\_s3\_bucket\_keyname\_prefix](#input\_datacompare\_s3\_bucket\_keyname\_prefix) | KeyName (folder structure) for s3 bucket to be used for datacompare IRSA role including trailing '/' (ex. myFolder/). | `string` | `""` | no |
| <a name="input_datacompare_s3_bucket_name"></a> [datacompare\_s3\_bucket\_name](#input\_datacompare\_s3\_bucket\_name) | Name of s3 bucket to be used for datacompare IRSA role. | `string` | `""` | no |
| <a name="input_deploy_argocd_helm"></a> [deploy\_argocd\_helm](#input\_deploy\_argocd\_helm) | Do you wish to bootstrap ArgoCD with the EKS cluster deployment? | `string` | `"false"` | no |
| <a name="input_deploy_istio_helm"></a> [deploy\_istio\_helm](#input\_deploy\_istio\_helm) | Do you wish to bootstrap Istio with the EKS cluster deployment? | `string` | `"false"` | no |
| <a name="input_desired_nodes_count"></a> [desired\_nodes\_count](#input\_desired\_nodes\_count) | Base number of EKS nodes to be maintained by the autoscaling group | `number` | `3` | no |
| <a name="input_ebs_volume_size"></a> [ebs\_volume\_size](#input\_ebs\_volume\_size) | EBS volume size backing each EKS node on creation | `number` | `100` | no |
| <a name="input_enable_cert_manager"></a> [enable\_cert\_manager](#input\_enable\_cert\_manager) | Create cert-manager helm release and associated IAM role | `bool` | `true` | no |
| <a name="input_external_cidr_blocks"></a> [external\_cidr\_blocks](#input\_external\_cidr\_blocks) | A list of IAM ARNs for those who will have full key permissions (kms:*) | `list(any)` | `[]` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The AWS EC2 instance type with which to spin up EKS nodes | `string` | `"m5.large"` | no |
| <a name="input_istio_version"></a> [istio\_version](#input\_istio\_version) | Version of Istio with which to bootstrap EKS cluster | `string` | `"1.17.2"` | no |
| <a name="input_kms_key_administrators"></a> [kms\_key\_administrators](#input\_kms\_key\_administrators) | A list of IAM ARNs for key administrators. If no value is provided, the current caller identity is used to ensure at least one key admin is available | `list(any)` | `[]` | no |
| <a name="input_kms_key_enable_default_policy"></a> [kms\_key\_enable\_default\_policy](#input\_kms\_key\_enable\_default\_policy) | Specifies whether to enable the default key policy | `bool` | `false` | no |
| <a name="input_kms_key_owners"></a> [kms\_key\_owners](#input\_kms\_key\_owners) | List of CIDR blocks (ex. 10.0.0.0/32) to allow access to eks cluster API | `list(any)` | `[]` | no |
| <a name="input_kubernetes_version_control_plane"></a> [kubernetes\_version\_control\_plane](#input\_kubernetes\_version\_control\_plane) | Desired Kubernetes version for control plane in EKS cluster | `string` | `"1.35"` | no |
| <a name="input_kubernetes_version_node_group"></a> [kubernetes\_version\_node\_group](#input\_kubernetes\_version\_node\_group) | Kubernetes version for node group in EKS cluster | `string` | `"1.35"` | no |
| <a name="input_max_nodes_count"></a> [max\_nodes\_count](#input\_max\_nodes\_count) | Maximum number of EKS nodes allowed by the autoscaling group | `number` | `5` | no |
| <a name="input_min_nodes_count"></a> [min\_nodes\_count](#input\_min\_nodes\_count) | Minimum number of EKS nodes allowed by the autoscaling group | `number` | `3` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the EKS cluster (an overwrite option to use a custom name) | `string` | `""` | no |
| <a name="input_otel_collector_namespace_and_service"></a> [otel\_collector\_namespace\_and\_service](#input\_otel\_collector\_namespace\_and\_service) | List of Kubernetes namespace and service for the OTEL Collector IRSA trust policy (format= [namespace:serviceName]). | `list(string)` | <pre>[<br/>  "observability:splunk-otel-collector"<br/>]</pre> | no |
| <a name="input_otel_collector_s3_bucket_name"></a> [otel\_collector\_s3\_bucket\_name](#input\_otel\_collector\_s3\_bucket\_name) | Name of S3 bucket for OTEL Collector log storage. | `string` | `""` | no |
| <a name="input_readonly_role_arn"></a> [readonly\_role\_arn](#input\_readonly\_role\_arn) | Optional AWS IAM Role arn used to authenticate into the EKS cluster for ReadOnly | `string` | `null` | no |
| <a name="input_readonly_role_arns"></a> [readonly\_role\_arns](#input\_readonly\_role\_arns) | List of AWS IAM Role ARNs for readonly access to the EKS cluster. If not provided, readonly\_role\_arn will be used if set. | `list(string)` | `[]` | no |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix for resource names | `string` | `"cdc-nbs"` | no |
| <a name="input_use_ecr_pull_through_cache"></a> [use\_ecr\_pull\_through\_cache](#input\_use\_ecr\_pull\_through\_cache) | Create and use ECR pull through caching for bootstrapped helm charts | `bool` | `false` | no |

### Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_admin_role_arns"></a> [admin\_role\_arns](#output\_admin\_role\_arns) | List of IAM role ARNs with admin access to the cluster |
| <a name="output_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#output\_cluster\_certificate\_authority\_data) | Base64-encoded certificate data required to communicate with the cluster |
| <a name="output_cluster_oidc_issuer_url"></a> [cluster\_oidc\_issuer\_url](#output\_cluster\_oidc\_issuer\_url) | The URL on the EKS cluster for the OpenID Connect identity provider |
| <a name="output_eks_aws_role_arn"></a> [eks\_aws\_role\_arn](#output\_eks\_aws\_role\_arn) | IAM role ARN of the EKS cluster |
| <a name="output_eks_cluster_endpoint"></a> [eks\_cluster\_endpoint](#output\_eks\_cluster\_endpoint) | Endpoint for your Kubernetes API server |
| <a name="output_eks_cluster_name"></a> [eks\_cluster\_name](#output\_eks\_cluster\_name) | The name of the EKS cluster |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | The ARN of the OIDC Provider if enable\_irsa = true |
| <a name="output_otel_collector_role_arn"></a> [otel\_collector\_role\_arn](#output\_otel\_collector\_role\_arn) | OTEL Collector IRSA role ARN — pass to helm install via --set serviceAccount.annotations |
| <a name="output_readonly_role_arns"></a> [readonly\_role\_arns](#output\_readonly\_role\_arns) | List of IAM role ARNs with readonly access to the cluster |
<!-- END_TF_DOCS -->
