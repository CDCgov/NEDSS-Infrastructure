terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.21.0"
    }
    grafana = {
      source  = "grafana/grafana"
      version = ">= 2.1.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.1.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.38.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.13.1"
    }
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

provider "grafana" {
  alias = "cloud"
  url   = "https://${module.grafana-workspace.amg-workspace_endpoint}"
  auth  = module.grafana-workspace.amg-workspace-api-key #grafana_service_account_token.admin-sa-token.key #
}