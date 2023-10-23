# prometheus workspace output
output "amp_workspace_id" {
  value = module.prometheus-workspace.amp_workspace_id
}
output "amp_workspace_endpoint" {
  value = module.prometheus-workspace.amp_workspace_endpoint
}

output "prommetheus_role_arn" {
  value = module.iam-role.prommetheus_role_arn
}

output "sns_topic_arn" {
  value = module.prometheus-workspace.sns_topic_arn
}

# grafana workspace output
output "amg-workspace_endpoint" {
  value = "grafana-workspace.amg-workspace_endpoint" # "https://${module.grafana-workspace.amg-workspace_endpoint}"
}

output "amg-workspace-api-key" {
  value = module.grafana-workspace.amg-workspace-api-key
}