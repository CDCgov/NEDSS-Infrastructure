module "iam" {
  source                    = "./modules/iam-role"
  resource_prefix           = var.resource_prefix
  oidc_provider_arn         = var.oidc_provider_arn
  oidc_provider             = replace(var.oidc_provider_url, "https://", "")
  service_account_namespace = var.namespace_name
  service_account_name      = var.service_account_name
  s3_bucket_arn             = var.s3_bucket_arn
  tags                      = var.tags
}
