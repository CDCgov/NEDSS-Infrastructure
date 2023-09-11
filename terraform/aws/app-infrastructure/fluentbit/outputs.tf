
output "bucket_name" {
  description = "S3 bucket name"
  value       = module.fluentbit-bucket.bucket_name
}

output "fluentbit_role_arn" {
  description = "fluentbit role arn"
  value       = module.iam.fluentbit_role_arn
}



