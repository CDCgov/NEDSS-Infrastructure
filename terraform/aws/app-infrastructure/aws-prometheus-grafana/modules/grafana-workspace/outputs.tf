output "amg-workspace_endpoint" {
  value = aws_grafana_workspace.amg.endpoint
}

output "amg-workspace_arn" {
  value = aws_grafana_workspace.amg.arn
}

output "amg-workspace_version" {
  value = aws_grafana_workspace.amg.grafana_version
}

output "amg-workspace-api-key" {
  value = aws_grafana_workspace_api_key.api_key.key
}