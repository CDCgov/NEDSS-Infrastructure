# Serial: 2024121601

module "fluentbit" {

  source           = "git::https://github.com/CDCgov/NEDSS-Infrastructure.git//terraform/aws/app-infrastructure/fluentbit?ref=v1.2.22"
  eks_aws_role_arn = "arn:aws:iam::${var.target_account_id}:role/cdc-terraform-user-cross-account-role"

  # source                             = "../../../../NEDSS-Infrastructure/terraform/aws/app-infrastructure/fluentbit"
  # only use this to override for local use this will be used to find path to values file
  # path_to_fluentbit                   = "../../../../NEDSS-Infrastructure/terraform/aws/app-infrastructure/fluentbit"

  # SAMPLES
  #source                             = "../app-infrastructure/fluentbit"
  #path_to_fluentbit                  = "../app-infrastructure/fluentbit"
  #eks_aws_role_arn                   = "arn:aws:iam::${var.target_account_id}:role/${var.aws_admin_role_name}"


  oidc_provider_arn                  = module.eks_nbs.oidc_provider_arn
  oidc_provider_url                  = module.eks_nbs.cluster_oidc_issuer_url # replace(module.eks_nbs.cluster_oidc_issuer_url, "https://", "")
  tags                               = var.tags
  eks_cluster_endpoint               = module.eks_nbs.eks_cluster_endpoint
  cluster_certificate_authority_data = module.eks_nbs.cluster_certificate_authority_data
  eks_cluster_name                   = module.eks_nbs.eks_cluster_name
  # now created if it doesn't exist in fluentbit module
  namespace_name  = var.observability_namespace_name
  resource_prefix = var.resource_prefix
  #bucket_name     = var.fluentbit_bucket_name
  bucket_name = module.fluentbit-bucket.bucket_name
  # this defaults to false
  force_destroy_log_bucket = var.fluentbit_force_destroy_log_bucket
  # only needed if overriding for side-by-side etc
  #bucket_name                        = "cdc-nbs-<accountname>-fluentbit-logs-<account-id>"
}
