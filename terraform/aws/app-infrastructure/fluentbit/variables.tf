variable "resource_prefix" {
  type        = string
  description = "Prefix for resource names"
  default     = "cdc-nbs"
}

variable "bucket_name" {
  type        = string
  description = "Precreated (may be referenced from another module) S3 bucket into which logs are placed."
}

variable "tags" {
  type        = map(string)
  description = "tags applied to all resources"
}
variable "oidc_provider_arn" {
  type        = string
  description = "the ARN of the OIDC provider"
}
variable "oidc_provider_url" {
  type        = string
  description = "the URL of the OIDC provider"
}
# variable "SERVICE_ACCOUNT_NAMESPACE" {
#   type        = string
#   description = "the namespace for service account for fluentbit"
#   # default     = "observability"

# }
# variable "service_account_name" {
#   type        = string
#   description = "the name of the service account for fluentbit"
#   default     = "fluentbit-service-account"
# }

variable "force_destroy_log_bucket" {
  type        = string
  description = "Boolean that indicates all objects (including any locked objects) should be deleted from the bucket when the bucket is destroyed so that the bucket can be destroyed without error."
  default     = false
}

variable "path_to_fluentbit" {
  type        = string
  description = "path to the fluentbit module (No trailing slash needed)"
  default     = "./.terraform/modules/fluentbit/terraform/aws/app-infrastructure/fluentbit" # this path is path to TF .terraform folder once module downloaded  # "../modules/fluentbit"
}
variable "namespace_name" {
  type        = string
  description = "the namespace for service account for fluentbit (typically observability)"
  default     = "observability"
}

variable "release_name" {
  type        = string
  description = "the of the helm release"
  default     = "fluentbit"
}
variable "repository" {
  type        = string
  description = "the fluentbit repo name"
  default     = "https://fluent.github.io/helm-charts/"
}
variable "chart" {
  type        = string
  description = "fluentbit chart name"
  default     = "fluent-bit"
}

variable "cluster_certificate_authority_data" {
  type        = string
  description = "TBase64 encoded certificate data required to communicate with the cluster"
}

variable "eks_cluster_endpoint" {
  type        = string
  description = "The endpoint of the EKS cluster"
}

variable "eks_cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "eks_aws_role_arn" {
  type        = string
  description = "IAM role ARN of the EKS cluster"
}

variable "log_group_name" {
  type        = string
  description = "The name of CloudWatch log group"
  default     = "fluent-bit-cloudwatch"
}

variable "values_file_path" {
  type        = string
  description = "path to the values.yaml file"
  default     = "./.terraform/modules/fluentbit/terraform/aws/app-infrastructure/fluentbit/modules/helm-release/values.yaml" 
}