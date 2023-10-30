module "prometheus" {
  source                             = "../app-infrastructure/aws-prometheus-grafana"
  values_file_path                   = "../app-infrastructure/aws-prometheus-grafana/modules/prometheus-helm/values.yaml"
  resource_prefix                    = var.resource_prefix
  oidc_provider_arn                  = module.eks_nbs.oidc_provider_arn
  oidc_provider_url                  = module.eks_nbs.cluster_oidc_issuer_url # replace(module.eks_nbs.cluster_oidc_issuer_url, "https://", "")
  tags                               = var.tags
  eks_cluster_endpoint               = module.eks_nbs.eks_cluster_endpoint
  cluster_certificate_authority_data = module.eks_nbs.cluster_certificate_authority_data
  eks_cluster_name                   = module.eks_nbs.eks_cluster_name
  eks_aws_role_arn                   = "arn:aws:iam::${var.target_account_id}:role/cdc-terraform-user-cross-account-role"
  vpc_id                             = module.modernization-vpc.vpc_id
  private_subnet_ids                 = module.modernization-vpc.private_subnets
  vpc_cidr_block                     = module.modernization-vpc.vpc_cidr_block
  namespace_name                     = module.eks_nbs.precreated_observability_namespace_name
}
