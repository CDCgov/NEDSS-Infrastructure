data "aws_caller_identity" "current" {}

variable "resource_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "cdc-nbs"
}

variable "oidc_provider_arn" {
  description = "the ARN of the OIDC provider"
  type        = string
}

variable "oidc_provider_url" {
  description = "the URL of the OIDC provider"
  type        = string
}

variable "region" {
  description = "aws region"
  type        = string
  default     = "us-east-1"
}
####################################################

variable "namespace_name" {
  description = "namespace name"
  type        = string
  default     = "observability"
}

variable "repository" {
  description = "prometheus repository location"
  type        = string
  default     = "https://prometheus-community.github.io/helm-charts/"
}

variable "chart" {
  description = "prometheus helm chart name"
  type        = string
  default     = "prometheus"
}

variable "retention_in_days" {
  description = "number of days to retain logs"
  type        = number
  default     = 30
}

variable "data_sources" {
  description = "the datasource for grafana; in this case Prometheus"
  type        = list(any)
  default     = ["PROMETHEUS"]
}

variable "tags" {
  type = map(string)
}

variable "dependency_update" {
  description = "update all dependencies"
  type        = bool
  default     = true
}

variable "lint" {
  description = "linting the helm chart"
  type        = bool
  default     = true
}

variable "force_update" {
  description = "force update in new deployments"
  type        = bool
  default     = true
}

variable "cluster_certificate_authority_data" {
  description = "TBase64 encoded certificate data required to communicate with the cluster"
  type        = string
}

variable "eks_cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  type        = string
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "eks_aws_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  type        = string
}
