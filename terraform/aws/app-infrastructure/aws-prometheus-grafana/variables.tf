data "aws_caller_identity" "current" {}
# variable "env" {}

variable "vpc_id" {
  type = string
  description = "VPC id"
}
variable "vpc_cidr_block" {
  type = string
  description = "VPC cidr block"
}
variable "private_subnet_ids" { 
  type = list
  description = "subnets for the prometheus workspace"
  }

# variable "OIDC_PROVIDER" {
#   type = string
#   description = "OIDC provider ID"
# } 

variable "OIDC_PROVIDER_ARN" {
  type        = string
  description = "the ARN of the OIDC provider"
}
variable "OIDC_PROVIDER_URL" {
  type        = string
  description = "the URL of the OIDC provider"
}

variable "region" {
  type = string
  description = "aws region"
  default = "us-east-1"
}
####################################################
variable "prometheus_sg_name" {
  type = string
  description = "aws prometheus vpc endpoint security group name"
  default = "amp_vpc_endpoint_sg"
}

variable "namespace_name" {
  type = string
  description = "namespace name"
  default = "observability"
}

variable "grafana_sg_name" {
  type = string
  description = "aws grafana vpc endpoint security group name"
  default = "amg_vpc_endpoint_sg"
}


variable "SERVICE_ACCOUNT_NAMESPACE" {
  type = string
  description = "service account namespace name"
  default = "observability"
}
variable "SERVICE_ACCOUNT_AMP_INGEST_NAME" {
  type = string
  description = "prometheus service account name"
  default = "prometheus-service-account"
}

variable "repository" {
  type = string
  description = "prometheus repository location"
  default = "https://prometheus-community.github.io/helm-charts/"
}
variable "chart" {
  type = string
  description = "prometheus helm chart name"
  default = "prometheus"
}
# variable "WORKSPACE_ID" {}
# variable "IAM_PROXY_PROMETHEUS_ROLE_ARN" {}

# variable "workspace_name" {}
variable "retention_in_days" {
  type = number
  description = "number of days to retain logs"
  default = 30
}
# variable "name_prefix" {}

variable "alias" {
  type = string
  description  = "alias for prometheus workspace"
  default = "cdc-nbs-prometheus-metrics"
}
variable "values_file_path" {
  type = string
  description = "path to the values.yaml file"
  default = "../modules/aws-prometheus-grafana/modules/prometheus-helm/values.yaml"
}
variable "prometheus_endpoint" {
  type = string
  description = "vpc endpoint for prometheus"
  default = "prometheus_vpc_endpoint"
}
variable "grafana_endpoint" {
  type = string
  description = "vpc endpoint for grafana"
  default = "grafana_vpc_endpoint"
}

variable "data_sources" {
  type = list
  description = "the datasource for grafana; in this case Prometheus"
  default = ["PROMETHEUS"]
}
variable "grafana_workspace_name" {
  type = string
  description = "the aws grafana workspace name"
  default = "cdc-nbs-grafana-metrics"
}

variable "tags" {
    type = map(string)
  }

variable "dependency_update" {
  type = bool
  description = "update all dependencies"
  default     = true 
  } 

variable "lint" {
  type = bool
  description = "linting the helm chart"
  default     = true
  }

variable "force_update" {
  type = bool
  description = "force update in new deployments"
  default     = true
  }

  variable "eks_cluster_endpoint" {} # = module.eks_nbs.eks_cluster_endpoint
  variable "cluster_certificate_authority_data" {} #= module.eks_nbs.cluster_certificate_authority_data
  variable "eks_cluster_name" {} # = module.eks_nbs.eks_cluster_name
  variable "eks_aws_role_arn" {} # = module.eks_nbs.eks_aws_role_arn








