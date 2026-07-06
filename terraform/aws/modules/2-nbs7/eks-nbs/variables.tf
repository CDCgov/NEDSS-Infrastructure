variable "resource_prefix" {
  type        = string
  description = "Prefix for resource names"
  default     = "cdc-nbs"
}

variable "name" {
  description = "Name of the EKS cluster (an overwrite option to use a custom name)"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "The AWS VPC ID to deploy in which to deploy the cluster"
  type        = string
}

variable "subnets" {
  description = "List of the AWS private subnets ids associated with the supplied vpc_id to deploy in which to deploy the cluster"
  type        = list(string)
}

variable "instance_type" {
  description = "The AWS EC2 instance type with which to spin up EKS nodes"
  type        = string
  default     = "m5.large"
}

variable "aws_role_arn" {
  description = "AWS IAM Role arn used to authenticate into the EKS cluster"
  type        = string
}

variable "readonly_role_arn" {
  description = "Optional AWS IAM Role arn used to authenticate into the EKS cluster for ReadOnly"
  type        = string
  default     = null
}

variable "admin_role_arns" {
  description = "List of AWS IAM Role ARNs for admin access to the EKS cluster. If not provided, aws_role_arn will be used."
  type        = list(string)
  default     = []
}

variable "readonly_role_arns" {
  description = "List of AWS IAM Role ARNs for readonly access to the EKS cluster. If not provided, readonly_role_arn will be used if set."
  type        = list(string)
  default     = []
}

variable "cluster_version" {
  description = "Version of the AWS EKS cluster to provision"
  default     = "1.35"
}

variable "desired_nodes_count" {
  description = "Base number of EKS nodes to be maintained by the autoscaling group"
  type        = number
  default     = 3
}

variable "max_nodes_count" {
  description = "Maximum number of EKS nodes allowed by the autoscaling group"
  type        = number
  default     = 5
}

variable "min_nodes_count" {
  description = "Minimum number of EKS nodes allowed by the autoscaling group"
  type        = number
  default     = 3
}

variable "ami_release_version" {
  description = "The AMI release version for the Node Group of the EKS cluster"
  type        = string
  default     = "1.35.4-20260423"

  # This variable allows the user of this module to pin an "AMI release version" to be specified for the Node Group of their EKS cluster. If this variable is null, then every few weeks whenever AWS releases a new version of the AMI then for the user's Terraform code a `terraform plan` will report a change to their Node Group to the new AMI version.

  # Per https://docs.aws.amazon.com/eks/latest/userguide/eks-linux-ami-versions.html the format of these AMIs is:
  #  * k8s_major_version.k8s_minor_version.k8s_patch_version-release_date

  # (Note that https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/modules/eks-managed-node-group/variables.tf specifies a default value of "AL2023_x86_64_STANDARD" for the ami_type variable.)
  # Here are a couple example values of ami_release_version, and to the right of "->" is info about the corresponding AMI:
  #  * 1.35.2-20260318 -> ami-009f1fe7d56695348 amazon-eks-node-al2023-x86_64-standard-1.35-v20260318 , Creation date 2026-03-19 , Deprecation 2028-03-19.
  #  * 1.35.4-20260423 -> ami-04ab87c8cf3840590 amazon-eks-node-al2023-x86_64-standard-1.35-v20260423 , Creation date 2026-04-24 , Deprecation 2028-04-24.

  # The following command (from the https://docs.aws.amazon.com/eks/latest/userguide/retrieve-ami-id.html page) on 5/4/2026 printed the following:
  #   ❯ aws ssm get-parameter --name /aws/service/eks/optimized-ami/1.35/amazon-linux-2023/x86_64/standard/recommended/image_id --region us-east-2 --query "Parameter.Value" --output text
  #   ami-04ab87c8cf3840590
  # Another way to get the latest recommended AMI is to look at: https://github.com/awslabs/amazon-eks-ami/blob/main/CHANGELOG.md

  # To summarize, for simplicity and ease of use (e.g. so users can have predictable and controlled output for their `terraform plan` commands) it is recommended:
  # * that when you are writing new code to use this module, that you get the Release version of the latest recommended AMI for the version of Kubernetes you're using (i.e. the kubernetes_version variable above) and specify that Release version as the value you provide for this ami_release_version variable,
  # * and then going forward from there that you occasionally step-up to new AMI versions at least frequently enough to avoid using a version that has become deprecated.
}

variable "ebs_volume_size" {
  description = "EBS volume size backing each EKS node on creation"
  type        = number
  default     = 100
}

variable "deploy_argocd_helm" {
  description = "Do you wish to bootstrap ArgoCD with the EKS cluster deployment?"
  type        = string
  default     = "false"
}

variable "argocd_version" {
  description = "Version of ArgoCD with which to bootstrap EKS cluster"
  type        = string
  default     = "5.23.3"
}

variable "deploy_istio_helm" {
  description = "Do you wish to bootstrap Istio with the EKS cluster deployment?"
  type        = string
  default     = "false"
}

variable "istio_version" {
  description = "Version of Istio with which to bootstrap EKS cluster"
  type        = string
  default     = "1.17.2"
}

variable "use_ecr_pull_through_cache" {
  description = "Create and use ECR pull through caching for bootstrapped helm charts"
  type        = bool
  default     = false
}

variable "allow_endpoint_public_access" {
  description = "Allow both public and private access to EKS api endpoint"
  type        = bool
  default     = false
}

variable "external_cidr_blocks" {
  description = "A list of IAM ARNs for those who will have full key permissions (kms:*)"
  type        = list(any)
  default     = []
}

variable "kms_key_owners" {
  description = "List of CIDR blocks (ex. 10.0.0.0/32) to allow access to eks cluster API"
  type        = list(any)
  default     = []
}

variable "kms_key_administrators" {
  description = "A list of IAM ARNs for key administrators. If no value is provided, the current caller identity is used to ensure at least one key admin is available"
  type        = list(any)
  default     = []
}

variable "kms_key_enable_default_policy" {
  description = "Specifies whether to enable the default key policy"
  type        = bool
  default     = false
}

variable "enable_cert_manager" {
  description = "Create cert-manager helm release and associated IAM role"
  type = bool
  default = true
}

variable "cert_manager_hosted_zone_arns" {
  description = "ARNs for Route 53 hosted zones that Cert Manager can access"
  type        = list(string)
}

variable "addons" {
  description = "Map of cluster addon configurations to enable for the cluster. Addon name can be the map keys or set with `name`"
  type = map(object({
    name                 = optional(string) # will fall back to map key
    before_compute       = optional(bool, false)
    most_recent          = optional(bool, true)
    addon_version        = optional(string)
    configuration_values = optional(string)
    pod_identity_association = optional(list(object({
      role_arn        = string
      service_account = string
    })))
    preserve                    = optional(bool, true)
    resolve_conflicts_on_create = optional(string, "OVERWRITE")
    resolve_conflicts_on_update = optional(string, "OVERWRITE")
    service_account_role_arn    = optional(string)
    timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
    }), {})
    tags = optional(map(string), {})
  }))
  default = {
    coredns    = {} # https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html
    kube-proxy = {} # https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html
    vpc-cni = {     # https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html
      before_compute = true
    }
  }
}

# OTEL Collector optional service
variable "create_otel_collector_irsa" {
  description = "Create IRSA role and IAM policy for the OTEL Collector S3 log export?"
  type        = bool
  default     = false
}

variable "otel_collector_s3_bucket_name" {
  description = "Name of S3 bucket for OTEL Collector log storage."
  type        = string
  default     = ""
}

variable "otel_collector_namespace_and_service" {
  description = "List of Kubernetes namespace and service for the OTEL Collector IRSA trust policy (format= [namespace:serviceName])."
  type        = list(string)
  default     = ["observability:splunk-otel-collector"]
}

# Datacompare optional service
variable "create_datacompare_irsa" {
  description = "Create an IAM roles for service accounts (IRSA) and IAM policy for the datacompare service?"
  type        = bool
  default     = false
}

variable "datacompare_namespace_and_service" {
  description = "List of Kubernetes namespace and services to be included in the datacompare IRSA trust policy (format= [namespace:serviceName])."
  type        = list(string)
  default     = ["default:data-compare-api-service", "default:data-compare-processor-service"]
}

variable "datacompare_s3_bucket_name" {
  description = "Name of s3 bucket to be used for datacompare IRSA role."
  type        = string
  default     = ""
}
variable "datacompare_s3_bucket_keyname_prefix" {
  description = "KeyName (folder structure) for s3 bucket to be used for datacompare IRSA role including trailing '/' (ex. myFolder/)."
  type        = string
  default     = ""

  validation {
    # Check if the string is empty OR matches the regex for ending in /
    condition     = var.datacompare_s3_bucket_keyname_prefix == "" || can(regex("/$", var.datacompare_s3_bucket_keyname_prefix))
    error_message = "The datacompare_s3_bucket_keyname_prefix variable must be an empty string or end with a forward slash (/). Example: 'myFolder/' or \"\"."
  }
}
