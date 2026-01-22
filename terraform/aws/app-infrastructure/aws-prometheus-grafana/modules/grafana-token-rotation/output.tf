output "secret_arn" {
  description = "ARN of the Secrets Manager secret containing the Grafana token"
  value       = aws_secretsmanager_secret.grafana_token.arn
}

output "secret_id" {
  description = "ID of the Secrets Manager secret containing the Grafana token"
  value       = aws_secretsmanager_secret.grafana_token.id
}

output "secret_name" {
  description = "Name of the Secrets Manager secret containing the Grafana token"
  value       = aws_secretsmanager_secret.grafana_token.name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function that rotates the token"
  value       = aws_lambda_function.token_rotation.arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function that rotates the token"
  value       = aws_lambda_function.token_rotation.function_name
}