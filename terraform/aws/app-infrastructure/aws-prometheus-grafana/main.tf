module "vpc-endpoints" {
    source = "./modules/vpc-endpoints"
    tags = var.tags
    region = var.region
    vpc_id = var.vpc_id
    vpc_cidr_block = var.vpc_cidr_block
    private_subnet_ids = var.private_subnet_ids
    grafana_sg_name = var.grafana_sg_name
    prometheus_sg_name = var.prometheus_sg_name
    prometheus_endpoint = var.prometheus_endpoint
    grafana_endpoint = var.grafana_endpoint
}

module "iam-role" {
    source = "./modules/iam-roles"
    tags = var.tags
    # AWS_ACCOUNT_ID = data.aws_caller_identity.current.account_id
    OIDC_PROVIDER = replace(var.OIDC_PROVIDER_URL, "https://", "") # var.OIDC_PROVIDER
    OIDC_PROVIDER_ARN         = var.OIDC_PROVIDER_ARN
    SERVICE_ACCOUNT_NAMESPACE = var.SERVICE_ACCOUNT_NAMESPACE
    SERVICE_ACCOUNT_AMP_INGEST_NAME = var.SERVICE_ACCOUNT_AMP_INGEST_NAME  
}

module "prometheus-workspace" {
    source = "./modules/prometheus-workspace"
    depends_on = [module.vpc-endpoints]
    alias = var.alias
    retention_in_days = var.retention_in_days
    tags = var.tags
    region = var.region
}

module "k8s-namespace" {
    source = "./modules/k8s-namespace"
    create_namespace = false
    namespace_name = var.namespace_name
}

module "prometheus-helm" {
    source = "./modules/prometheus-helm"
    depends_on = [module.prometheus-workspace, module.iam-role]  
    namespace_name = var.namespace_name
    region = var.region
    repository = var.repository
    chart = var.chart
    WORKSPACE_ID = module.prometheus-workspace.amp_workspace_id
    IAM_PROXY_PROMETHEUS_ROLE_ARN = module.iam-role.prommetheus_role_arn
    values_file_path = var.values_file_path
    dependency_update = var.dependency_update
    lint = var.lint
    force_update = var.force_update 
}

module "grafana-workspace" {
    source = "./modules/grafana-workspace"
    depends_on = [module.prometheus-workspace]
    tags = var.tags
    data_sources = var.data_sources
    grafana_workspace_name = var.grafana_workspace_name
    endpoint_url = module.prometheus-workspace.amp_workspace_endpoint
    amp_workspace_id = module.prometheus-workspace.amp_workspace_id
    region = var.region
}

module "grafana-dashboard" {
    source = "./modules/grafana-dashboard"
    depends_on = [module.grafana-workspace]
    grafana_workspace_url = "https://${module.grafana-workspace.amg-workspace_endpoint}"
    amg_api_token = module.grafana-workspace.amg-workspace-api-key
    amp_url = module.prometheus-workspace.amp_workspace_endpoint
}