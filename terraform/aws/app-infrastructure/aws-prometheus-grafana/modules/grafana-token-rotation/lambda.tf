data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_code"
  output_path = "${path.module}/lambda_code.zip"
}

resource "aws_lambda_function" "token_rotation" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.resource_prefix}-grafana-token-rotation"
  role             = aws_iam_role.lambda_rotation_role.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.11"
  timeout          = 60
  memory_size      = 128

  environment {
    variables = {
      GRAFANA_WORKSPACE_ID  = var.grafana_workspace_id
      SERVICE_ACCOUNT_ID    = var.service_account_id
      SECRET_NAME           = aws_secretsmanager_secret.grafana_token.name
      TOKEN_EXPIRATION_DAYS = var.token_expiration_days
      RESOURCE_PREFIX       = var.resource_prefix
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.resource_prefix}-grafana-token-rotation"
    }
  )
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.resource_prefix}-grafana-token-rotation"
  retention_in_days = 14

  tags = var.tags
}