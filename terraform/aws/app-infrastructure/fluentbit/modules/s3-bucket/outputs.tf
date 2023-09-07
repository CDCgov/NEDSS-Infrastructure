output "bucket_name" {
  description = "S3 bucket arn"
  value       = aws_s3_bucket.log_bucket.id
}


