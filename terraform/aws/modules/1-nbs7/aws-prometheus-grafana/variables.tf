data "aws_caller_identity" "current" {}

variable "resource_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "cdc-nbs"
}

variable "oidc_provider_arn" {
  description = "The ARN of the OIDC provider"
  type        = string
}

variable "oidc_provider_url" {
  description = "The URL of the OIDC provider"
  type        = string
}

variable "region" {
  description = "The AWS region to use for the resources"
  type        = string
  default     = "us-east-1"
}
####################################################

variable "namespace_name" {
  description = "The name of the Kubernetes namespace"
  type        = string
  default     = "observability"
}

variable "repository" {
  description = "The URL of the Prometheus Helm chart repository"
  type        = string
  default     = "https://prometheus-community.github.io/helm-charts/"
}

variable "chart" {
  description = "The name of the Prometheus Helm chart"
  type        = string
  default     = "prometheus"
}

variable "retention_in_days" {
  description = "The number of days to keep the log data"
  type        = number
  default     = 30
}

variable "data_sources" {
  description = "The list of Grafana data sources"
  type        = list(any)
  default     = ["PROMETHEUS"]
}

variable "tags" {
  description = "A map of tags to add to the resources"
  type        = map(string)
}

variable "dependency_update" {
  description = "Set to true to update the Helm chart dependencies before install"
  type        = bool
  default     = true
}

variable "lint" {
  description = "Set to true to lint the Helm chart before install"
  type        = bool
  default     = true
}

variable "force_update" {
  description = "Set to true to force resource updates through a replace operation"
  type        = bool
  default     = true
}

variable "cluster_certificate_authority_data" {
  description = "The base64-encoded certificate data needed to talk to the cluster"
  type        = string
}

variable "eks_cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  type        = string
}

variable "eks_cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "eks_aws_role_arn" {
  description = "The IAM role ARN of the EKS cluster"
  type        = string
}