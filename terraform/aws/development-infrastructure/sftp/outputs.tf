output "bucket_name" {
  description = "The name of the S3 bucket used for HL7 file uploads"
  value       = aws_s3_bucket.hl7.id
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table for logging HL7 processing errors"
  value       = aws_dynamodb_table.hl7_errors.name
}

output "sns_error_topic_arn" {
  description = "ARN of the SNS topic for error notifications"
  value       = try(aws_sns_topic.error[0].arn, null)
  condition   = var.enable_error_notifications
}

output "sns_success_topic_arn" {
  description = "ARN of the SNS topic for success notifications"
  value       = try(aws_sns_topic.success[0].arn, null)
  condition   = var.enable_success_notifications
}

output "sns_summary_topic_arn" {
  description = "ARN of the SNS topic for summary notifications"
  value       = try(aws_sns_topic.summary[0].arn, null)
  condition   = var.enable_summary_notifications
}

