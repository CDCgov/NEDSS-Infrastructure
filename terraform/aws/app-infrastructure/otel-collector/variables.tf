variable "resource_prefix" {
  type        = string
  description = "Prefix for resource names"
  default     = "cdc-nbs"
}

variable "s3_bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket for OTEL log storage"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all resources"
}

variable "oidc_provider_arn" {
  type        = string
  description = "The ARN of the EKS cluster OIDC provider"
}

variable "oidc_provider_url" {
  type        = string
  description = "The URL of the EKS cluster OIDC provider"
}

variable "namespace_name" {
  type        = string
  description = "Kubernetes namespace where OTEL collector is deployed"
  default     = "observability"
}

variable "service_account_name" {
  type        = string
  description = "Name of the Kubernetes ServiceAccount used by the OTEL collector"
  default     = "splunk-otel-collector"
}
