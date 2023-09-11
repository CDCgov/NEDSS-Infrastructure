
provider "helm" {
  kubernetes {
    host                   = var.eks_cluster_endpoint # module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data) # base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.eks_cluster_name, "--role-arn", var.eks_aws_role_arn]
      command     = "aws"
    }
  }
}

provider "kubernetes" {
  host                   = var.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

#https://registry.terraform.io/providers/grafana/grafana/1.30.0
# terraform {
#   required_providers {
#     grafana = {
#       source  = "grafana/grafana"
#       version = "2.1.0"
#     }
#   }
# }

# provider "grafana" {
#   alias="cloud"
#   url  = var.grafana_workspace_url
#   auth =  var.amg_api_token  #grafana_service_account_token.admin-sa-token.key #
# }
