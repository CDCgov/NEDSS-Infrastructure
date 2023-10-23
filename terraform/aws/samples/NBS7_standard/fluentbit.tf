module "fluentbit" {
  source            = "../app-infrastructure/fluentbit"
  path_to_fluentbit = "../app-infrastructure/fluentbit"
  OIDC_PROVIDER_ARN = module.eks_nbs.oidc_provider_arn
  OIDC_PROVIDER_URL = module.eks_nbs.cluster_oidc_issuer_url  # replace(module.eks_nbs.cluster_oidc_issuer_url, "https://", "")
  tags              = var.tags
  eks_cluster_endpoint = module.eks_nbs.eks_cluster_endpoint
  cluster_certificate_authority_data = module.eks_nbs.cluster_certificate_authority_data
  eks_cluster_name = module.eks_nbs.eks_cluster_name
  eks_aws_role_arn = "arn:aws:iam::${var.target_account_id}:role/${var.aws_admin_role_name}"
  namespace_name = module.eks_nbs.precreated_observability_namespace_name
}

