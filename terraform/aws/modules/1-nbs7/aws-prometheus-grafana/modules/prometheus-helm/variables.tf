variable "region" {
  description = "The AWS region to use for the resources"
  type        = string
}

variable "workspace_id" {
  description = "The ID of the Amazon Managed Prometheus workspace"
  type        = string
}

variable "iam_proxy_prometheus_role_arn" {
  description = "The ARN of the IAM role used by the Prometheus proxy"
  type        = string
}

variable "repository" {
  description = "The URL of the Helm chart repository"
  type        = string
}

variable "chart" {
  description = "The name of the Helm chart"
  type        = string
}

variable "namespace_name" {
  description = "The name of the Kubernetes namespace"
  type        = string
}

variable "dependency_update" {
  description = "Set to true to update the Helm chart dependencies before install"
  type        = bool
}

variable "lint" {
  description = "Set to true to lint the Helm chart before install"
  type        = bool
}

variable "force_update" {
  description = "Set to true to force resource updates through a replace operation"
  type        = bool
}

variable "service_account_amp_ingest_name" {
  description = "The name of the service account used to ingest data into Amazon Managed Prometheus"
  type        = string
}