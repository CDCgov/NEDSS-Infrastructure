# Prometheus workspace outputs
output "amp_workspace_id" {
  description = "The ID of the Prometheus workspace"
  value       = module.prometheus-workspace.amp_workspace_id
}

output "amp_workspace_endpoint" {
  description = "The endpoint of the Prometheus workspace"
  value       = module.prometheus-workspace.amp_workspace_endpoint
}

output "prometheus_role_arn" {
  description = "The ARN of the Prometheus IAM role"
  value       = module.iam-role.prometheus_role_arn
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic for Prometheus alerts"
  value       = module.prometheus-workspace.sns_topic_arn
}

# Grafana workspace outputs
output "amg-workspace_endpoint" {
  description = "The endpoint of the Grafana workspace"
  value       = module.grafana-workspace.amg-workspace_endpoint
}

output "amg-workspace-id" {
  description = "The ID of the Grafana workspace"
  value       = module.grafana-workspace.amg-workspace-id
}

# Grafana token rotation outputs (NEW)
output "grafana-token-secret-arn" {
  description = "ARN of the Secrets Manager secret containing the Grafana token"
  value       = module.grafana-token-rotation.secret_arn
}

output "grafana-token-secret-name" {
  description = "Name of the Secrets Manager secret containing the Grafana token"
  value       = module.grafana-token-rotation.secret_name
}

output "grafana-token-rotation-lambda" {
  description = "Name of the Lambda function that rotates the Grafana token"
  value       = module.grafana-token-rotation.lambda_function_name
}

# NOTE: The following output has been REMOVED:
# - output "amg-workspace-api-key" (was directly exposing the API key)
#
# The token is now stored securely in Secrets Manager