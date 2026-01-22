output "amg-workspace_endpoint" {
  value = aws_grafana_workspace.amg.endpoint
}

output "amg-workspace_arn" {
  value = aws_grafana_workspace.amg.arn
}

output "amg-workspace_version" {
  value = aws_grafana_workspace.amg.grafana_version
}

output "amg-workspace-service-account-id" {
  description = "The ID of the Grafana service account"
  value       = aws_grafana_workspace_service_account.terraform_sa.id
}

output "amg-workspace-id" {
  description = "The ID of the Grafana workspace"
  value       = aws_grafana_workspace.amg.id
}

# NOTE: The following output has been REMOVED:
# - output "amg-workspace-api-key" (was referencing the deprecated API key)
#
# The token is now managed by Lambda and stored in Secrets Manager