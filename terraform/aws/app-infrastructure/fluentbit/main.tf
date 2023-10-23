
module "iam" {
  source                    = "./modules/iam-role"
  service_account_name      = "${var.resource_prefix}-fluentbit-svc-acc"
  oidc_provider_arn         = var.oidc_provider_arn
  oidc_provider             = replace(var.oidc_provider_url, "https://", "") # var.OIDC_PROVIDER
  service_account_namespace = var.namespace_name
  tags                      = var.tags
}

module "fluentbit-bucket" {
  source                   = "./modules/s3-bucket"
  depends_on               = [module.iam]
  bucket_name              = "${var.resource_prefix}-fluentbit-logs"
  tags                     = var.tags
  force_destroy_log_bucket = var.force_destroy_log_bucket
}

module "helm-release" {
  source               = "./modules/helm-release"
  depends_on           = [module.fluentbit-bucket, module.iam]
  bucket               = module.fluentbit-bucket.bucket_name
  release_name         = var.release_name
  repository           = var.repository
  chart                = var.chart
  fluentbit_role_arn   = module.iam.fluentbit_role_arn
  path_to_fluentbit    = var.path_to_fluentbit
  namespace            = var.namespace_name
  tags                 = var.tags
  service_account_name = "${var.resource_prefix}-fluentbit-svc-acc"
}

module "fluentbit-dashboard" {
  source     = "./modules/fluentbit-dashboard"
  depends_on = [module.helm-release]
}