output "amp_workspace_id" {
  value = aws_prometheus_workspace.amp_workspace.id
}

output "amp_workspace_endpoint" {
  value = aws_prometheus_workspace.amp_workspace.prometheus_endpoint
}

output "sns_topic_arn" {
  value = aws_sns_topic.prometheus-alerts.arn
}
