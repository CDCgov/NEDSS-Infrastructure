module "iam-role" {
  source = "./modules/iam-roles"
  tags   = var.tags
  # AWS_ACCOUNT_ID = data.aws_caller_identity.current.account_id
  oidc_provider                   = replace(var.oidc_provider_url, "https://", "") # var.oidc_provider
  oidc_provider_arn               = var.oidc_provider_arn
  service_account_namespace       = var.namespace_name
  service_account_amp_ingest_name = "${var.resource_prefix}-amp-svc-acc"
  resource_prefix = var.resource_prefix
}

module "prometheus-workspace" {
  source            = "./modules/prometheus-workspace"
  alias             = "${var.resource_prefix}-amp-metrics"
  retention_in_days = var.retention_in_days
  tags              = var.tags
  region            = data.aws_region.current.name 
  resource_prefix = var.resource_prefix
}

# module "k8s-namespace" {
#   source           = "./modules/k8s-namespace"
#   create_namespace = false
#   namespace_name   = var.namespace_name
# }

module "prometheus-helm" {
  source                        = "./modules/prometheus-helm"
  depends_on                    = [module.prometheus-workspace, module.iam-role]
  namespace_name                = var.namespace_name
  region                        = data.aws_region.current.name
  repository                    = var.repository
  chart                         = var.chart
  workspace_id                  = module.prometheus-workspace.amp_workspace_id
  iam_proxy_prometheus_role_arn = module.iam-role.prometheus_role_arn
  values_file_path              = var.values_file_path
  dependency_update             = var.dependency_update
  lint                          = var.lint
  force_update                  = var.force_update
  service_account_amp_ingest_name = "${var.resource_prefix}-amp-svc-acc"
}

module "grafana-workspace" {
  source                 = "./modules/grafana-workspace"
  depends_on             = [module.prometheus-workspace]
  tags                   = var.tags
  data_sources           = var.data_sources
  grafana_workspace_name = "${var.resource_prefix}-amg-metrics"  
  endpoint_url           = module.prometheus-workspace.amp_workspace_endpoint
  amp_workspace_id       = module.prometheus-workspace.amp_workspace_id
  region                 = data.aws_region.current
  resource_prefix   = var.resource_prefix
}

module "grafana-dashboard" {
  source = "./modules/grafana-dashboard"
  depends_on = [module.grafana-workspace.aws_grafana_workspace_api_key]
  providers = {
    grafana = grafana.cloud
  }  
  grafana_workspace_url = "https://${module.grafana-workspace.amg-workspace_endpoint}"
  amg_api_token         = module.grafana-workspace.amg-workspace-api-key
  amp_url               = module.prometheus-workspace.amp_workspace_endpoint
  region = data.aws_region.current.name
}