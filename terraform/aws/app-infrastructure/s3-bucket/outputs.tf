output "bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.log_bucket.id
}


