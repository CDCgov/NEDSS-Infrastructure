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
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.1.0, < 5.0.0"
    }
  }

  required_version = ">= 1.3.0"
}

# provider "helm" {
#   kubernetes = {
#     host                   = var.eks_cluster_endpoint                             # module.eks.cluster_endpoint
#     cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data) # base64decode(module.eks.cluster_certificate_authority_data)
#     token                  = data.aws_eks_cluster_auth.cluster.token
#   }
# }

# provider "kubernetes" {
#   host                   = var.eks_cluster_endpoint
#   cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
#   token                  = data.aws_eks_cluster_auth.cluster.token
# }