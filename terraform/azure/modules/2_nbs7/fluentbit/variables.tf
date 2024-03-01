variable "resource_prefix" {
  type        = string
  description = "Prefix for resource names"
  default     = "cdc-nbs"
}

variable "helm_version" {
  type        = string
  description = "Version of fluentbit helm chart to deploy"
  default     = "0.43.0"
}

variable "namespace" {
  type        = string
  description = "Kubernetes namespace for fluentbit resources"
  default     = "observability"
}

variable "blob_account_name" {
  type        = string
  description = "Azure account name for blob storage"  
  sensitive = true
}

variable "blob_shared_key" {
  type        = string
  description = "Azure shared for blob storage access"
  sensitive = true
}

