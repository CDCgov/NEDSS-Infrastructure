output "otel_collector_role_arn" {
  description = "OTEL Collector IAM role ARN (use with --set serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn=<ARN>)"
  value       = module.iam.otel_collector_role_arn
}
