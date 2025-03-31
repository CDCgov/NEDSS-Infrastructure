
output "bucket_name" {
  description = "The name of the S3 bucket used for HL7 file uploads"
  value       = aws_s3_bucket.hl7.id
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table for logging HL7 processing errors"
  value       = aws_dynamodb_table.hl7_errors.name
}

#output "sns_error_topic_arn" {
  #description = "ARN of the SNS topic for error notifications"
  #value       = length(aws_sns_topic.error) > 0 ? aws_sns_topic.error[0].arn : null
#}

#output "sns_success_topic_arn" {
  #description = "ARN of the SNS topic for success notifications"
  #value       = length(aws_sns_topic.success) > 0 ? aws_sns_topic.success[0].arn : null
#}

#output "sns_summary_topic_arn" {
  #description = "ARN of the SNS topic for summary notifications"
  #value       = length(aws_sns_topic.summary) > 0 ? aws_sns_topic.summary[0].arn : null
#}


output "sns_error_topic_arn" {
  value = aws_sns_topic.error.arn
}

output "sns_success_topic_arn" {
  value = aws_sns_topic.success.arn
}

output "sns_summary_topic_arn" {
  value = aws_sns_topic.summary.arn
}

