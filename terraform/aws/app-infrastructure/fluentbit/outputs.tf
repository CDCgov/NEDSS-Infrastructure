
output "bucket_name" {
  description = "S3 bucket name"
  value       = module.fluentbit-bucket.bucket_name
}

output "fluentbit_role_arn" {
  description = "fluentbit role arn"
  value       = module.iam.fluentbit_role_arn
}

output "fluentbit_role_arn-extract" {
  description = "fluentbit role arn trimmed"
  value       = replace(module.iam.fluentbit_role_arn, "arn:aws:iam::923971392097:role/", "")
}

