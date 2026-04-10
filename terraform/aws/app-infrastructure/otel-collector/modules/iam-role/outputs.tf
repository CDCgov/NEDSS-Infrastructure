output "otel_collector_role_arn" {
  description = "OTEL Collector IAM role ARN"
  value       = aws_iam_role.otel_collector_role.arn
}
