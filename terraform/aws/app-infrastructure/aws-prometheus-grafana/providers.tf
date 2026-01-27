terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.21.0, < 7.0.0"
    }
    grafana = {
      source  = "grafana/grafana"
      version = ">= 4.19.0, < 5.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.1.1, < 4.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.38.0, < 3.0.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.0.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0"
    }
    # NOTE: 'time' provider removed - no longer needed
  }
  required_version = ">= 1.13.3"
}

provider "helm" {
  kubernetes = {
    host                   = var.eks_cluster_endpoint                             # module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data) # base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

provider "kubernetes" {
  host                   = var.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
######################################
# Read Grafana token from Secrets Manager
######################################

data "aws_secretsmanager_secret_version" "grafana_token" {
  depends_on = [module.grafana-token-rotation]
  secret_id  = module.grafana-token-rotation.secret_id
}

locals {
  # Parse the JSON secret and extract the token
  grafana_secret = jsondecode(data.aws_secretsmanager_secret_version.grafana_token.secret_string)
  grafana_token  = local.grafana_secret["token"]
}

######################################
# Grafana provider - now uses token from Secrets Manager
######################################

provider "grafana" {
  alias = "cloud"
  url   = "https://${module.grafana-workspace.amg-workspace_endpoint}"
  auth  = local.grafana_token
}