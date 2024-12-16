# Serial: 2024121601

module "linkerd" {
  source = "git::https://github.com/CDCgov/NEDSS-Infrastructure.git//terraform/aws/app-infrastructure/linkerd?ref=v1.2.22"

  # Local testing
  # source  = "../../../../NEDSS-Infrastructure/terraform/aws/app-infrastructure/linkerd"

  # SAMPLES
  #source  = "../app-infrastructure/linkerd"

  eks_cluster_endpoint               = module.eks_nbs.eks_cluster_endpoint
  cluster_certificate_authority_data = module.eks_nbs.cluster_certificate_authority_data
  eks_cluster_name                   = module.eks_nbs.eks_cluster_name
}
