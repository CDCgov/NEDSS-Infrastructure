module "linkerd" {
  source = "../..//app-infrastructure/linkerd"

  eks_cluster_endpoint               = local.eks_cluster_endpoint
  cluster_certificate_authority_data = local.cluster_certificate_authority_data
  eks_cluster_name                   = local.eks_cluster_name
}
