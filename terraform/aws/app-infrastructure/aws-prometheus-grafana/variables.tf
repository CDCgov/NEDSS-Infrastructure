data "aws_caller_identity" "current" {}
# variable "env" {}
variable "resource_prefix" {
  type        = string
  description = "Prefix for resource names"
  default     = "cdc-nbs"
}

variable "oidc_provider_arn" {
  type        = string
  description = "the ARN of the OIDC provider"
}
variable "oidc_provider_url" {
  type        = string
  description = "the URL of the OIDC provider"
}

variable "region" {
  type        = string
  description = "aws region"
  default     = "us-east-1"
}
####################################################

variable "namespace_name" {
  type        = string
  description = "namespace name"
  default     = "observability"
}

variable "repository" {
  type        = string
  description = "prometheus repository location"
  default     = "https://prometheus-community.github.io/helm-charts/"
}
variable "chart" {
  type        = string
  description = "prometheus helm chart name"
  default     = "prometheus"
}

variable "retention_in_days" {
  type        = number
  description = "number of days to retain logs"
  default     = 30
}

variable "values_file_path" {
  type        = string
  description = "path to the values.yaml file"
  default     = "./.terraform/modules/prometheus/terraform/aws/app-infrastructure/aws-prometheus-grafana/modules/prometheus-helm/values.yaml" 
}

variable "data_sources" {
  type        = list(any)
  description = "the datasource for grafana; in this case Prometheus"
  default     = ["PROMETHEUS"]
}

variable "tags" {
  type = map(string)
}

variable "dependency_update" {
  type        = bool
  description = "update all dependencies"
  default     = true
}

variable "lint" {
  type        = bool
  description = "linting the helm chart"
  default     = true
}

variable "force_update" {
  type        = bool
  description = "force update in new deployments"
  default     = true
}

variable "cluster_certificate_authority_data" {
  type = string
  description = "TBase64 encoded certificate data required to communicate with the cluster"
}

variable "eks_cluster_endpoint" {
  type = string
  description = "The endpoint of the EKS cluster"
} 

variable "eks_cluster_name" {
  type = string
  description = "Name of the EKS cluster"
} 

variable "eks_aws_role_arn" {
  type = string
  description = "IAM role ARN of the EKS cluster"
}
