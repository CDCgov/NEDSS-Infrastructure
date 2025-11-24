
module "iam" {
  source                    = "./modules/iam-role"
  service_account_name      = "${var.resource_prefix}-fluentbit-svc-acc"
  oidc_provider_arn         = var.oidc_provider_arn
  oidc_provider             = replace(var.oidc_provider_url, "https://", "") # var.OIDC_PROVIDER
  service_account_namespace = var.namespace_name
  tags                      = var.tags
  resource_prefix           = var.resource_prefix
}

module "helm-release" {
  source                     = "./modules/helm-release"
  depends_on                 = [module.iam]
  bucket                     = var.bucket_name
  release_name               = var.release_name
  repository                 = var.repository
  chart                      = var.chart
  fluentbit_role_arn         = module.iam.fluentbit_role_arn
  path_to_fluentbit          = var.path_to_fluentbit
  namespace                  = var.namespace_name
  tags                       = var.tags
  service_account_name       = "${var.resource_prefix}-fluentbit-svc-acc"
  fluentbit_cwlogsgroup_name = "${var.resource_prefix}-fluent-bit-cloudwatch"
}

module "fluentbit-dashboard" {
  source          = "./modules/fluentbit-dashboard"
  log_group_name  = "${var.resource_prefix}-fluent-bit-cloudwatch"
  resource_prefix = var.resource_prefix
  depends_on      = [module.helm-release]
}
