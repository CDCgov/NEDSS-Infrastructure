# Serial: 2024042601

module "prometheus" {

  source           = "../app-infrastructure/aws-prometheus-grafana"
  values_file_path = "../app-infrastructure/aws-prometheus-grafana/modules/prometheus-helm/values.yaml"
  eks_aws_role_arn = "arn:aws:iam::${var.target_account_id}:role/${var.aws_admin_role_name}"

  oidc_provider_arn                  = module.eks_nbs.oidc_provider_arn
  oidc_provider_url                  = module.eks_nbs.cluster_oidc_issuer_url ##### replace(module.eks_nbs.cluster_oidc_issuer_url, "https://", "") #####
  tags                               = var.tags
  eks_cluster_endpoint               = module.eks_nbs.eks_cluster_endpoint
  cluster_certificate_authority_data = module.eks_nbs.cluster_certificate_authority_data
  eks_cluster_name                   = module.eks_nbs.eks_cluster_name
  # are the next three functionally replaced or just unused in second
  # instance of module?
  # vpc_id             = module.modernization-vpc.vpc_id
  # private_subnet_ids = module.modernization-vpc.private_subnets
  # vpc_cidr_block     = module.modernization-vpc.vpc_cidr_block

  namespace_name = var.observability_namespace_name

  resource_prefix = var.resource_prefix
}
