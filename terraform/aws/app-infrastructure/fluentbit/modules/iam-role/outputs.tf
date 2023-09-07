output "fluentbit_role_arn" {
  description = "fluentbit role arn"
  value       = aws_iam_role.fluentbit-role.arn
}
