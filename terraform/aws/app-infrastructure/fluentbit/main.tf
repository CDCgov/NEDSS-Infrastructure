
module "iam" {
  source                    = "./modules/iam-role"
  SERVICE_ACCOUNT_NAME      = var.SERVICE_ACCOUNT_NAME
  OIDC_PROVIDER_ARN         = var.OIDC_PROVIDER_ARN
  OIDC_PROVIDER             = replace(var.OIDC_PROVIDER_URL, "https://", "") # var.OIDC_PROVIDER
  SERVICE_ACCOUNT_NAMESPACE = var.namespace_name
  tags                      = var.tags
}

module "fluentbit-bucket" {
  source      = "./modules/s3-bucket"
  depends_on  = [module.iam]
  bucket_name = var.bucket_name
  tags        = var.tags
}

module "helm-release" {
  source               = "./modules/helm-release"
  depends_on           = [module.fluentbit-bucket, module.iam]
  bucket               = module.fluentbit-bucket.bucket_name
  release_name         = var.release_name
  repository           = var.repository
  chart                = var.chart
  FLUENTBIT_ROLE_ARN   = module.iam.fluentbit_role_arn
  path_to_fluentbit     = var.path_to_fluentbit
  namespace            = var.namespace_name
  tags                 = var.tags
  SERVICE_ACCOUNT_NAME = var.SERVICE_ACCOUNT_NAME
}


