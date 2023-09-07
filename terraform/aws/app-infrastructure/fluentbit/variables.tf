
variable "bucket_name" {
  type        = string
  description = "name of bucket to forward logs to"
  default     = "cdc-nbs-fluentbit-logs"
}
variable "tags" {
  type        = map(string)
  description = "tags applied to all resources"
}
variable "OIDC_PROVIDER_ARN" {
  type        = string
  description = "the ARN of the OIDC provider"
}
variable "OIDC_PROVIDER_URL" {
  type        = string
  description = "the URL of the OIDC provider"
}
# variable "SERVICE_ACCOUNT_NAMESPACE" {
#   type        = string
#   description = "the namespace for service account for fluentbit"
#   # default     = "observability"

# }
variable "SERVICE_ACCOUNT_NAME" {
  type        = string
  description = "the name of the service account for fluentbit"
  default     = "fluentbit-service-account"
}
variable "path_to_fluentbit" {
  type        = string
  description = "path to the fluentbit module (No trailing slash needed)"
  default     = "../modules/fluentbit"
}
variable "namespace_name" {
  type        = string
  description = "the namespace for service account for fluentbit (typically observability)"  
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

  variable "eks_cluster_endpoint" {} 
  variable "cluster_certificate_authority_data" {} 
  variable "eks_cluster_name" {} 
  variable "eks_aws_role_arn" {} 