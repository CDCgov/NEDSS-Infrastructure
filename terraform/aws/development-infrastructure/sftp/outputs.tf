
output "bucket_name" {
  description = "The name of the S3 bucket used for HL7 file uploads"
  value       = aws_s3_bucket.hl7.id
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table for logging HL7 processing errors"
  value       = aws_dynamodb_table.hl7_errors.name
}

output "sns_error_topic_arn" {
  value = aws_sns_topic.error.arn
}

output "sns_success_topic_arn" {
  value = aws_sns_topic.success.arn
}

output "sns_summary_topic_arn" {
  value = aws_sns_topic.summary.arn
}

output "sftp_usernames_and_dirs" {
  value = {
    for key, user in aws_transfer_user.sftp :
    key => {
      user_name   = user.user_name
      #home_dir    = user.home_directory_mappings[0].target
      home_dir = try(user.home_directory_mappings[0].target, null)
      public_key  = try(tls_private_key.user_keys[key].public_key_openssh, null)
      private_key = try(tls_private_key.user_keys[key].private_key_pem, null)
      password    = random_password.user_passwords[key].result
    }
  }
  sensitive = true
}

output "site_admins" {
  value = {
    for key, user in aws_transfer_user.site_admin :
    key => {
      user_name = user.user_name
      #home_dir  = user.home_directory_mappings[0].target
      home_dir = try(user.home_directory_mappings[0].target, null)
      password  = random_password.admin_passwords[key].result
    }
  }
  sensitive = true
}
