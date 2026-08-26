variable "tags" {
  description = "A map of tags to add to the resources"
  type        = map(string)
}

variable "oidc_provider" {
  description = "The OIDC provider for the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "The ARN of the OIDC provider for the EKS cluster"
  type        = string
}

variable "service_account_namespace" {
  description = "The Kubernetes namespace of the service account"
  type        = string
}

variable "service_account_amp_ingest_name" {
  description = "The name of the service account used to ingest data into Amazon Managed Prometheus"
  type        = string
}

variable "resource_prefix" {
  description = "The prefix text to add to the start of each resource name"
  type        = string
}