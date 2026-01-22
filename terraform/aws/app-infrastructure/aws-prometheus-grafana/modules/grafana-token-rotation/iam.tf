# IAM Role for Lambda
resource "aws_iam_role" "lambda_rotation_role" {
  name = "${var.resource_prefix}-grafana-token-rotation-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Policy for Grafana operations
resource "aws_iam_policy" "grafana_policy" {
  name        = "${var.resource_prefix}-grafana-token-rotation-grafana-policy"
  description = "Allows Lambda to manage Grafana service account tokens"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "grafana:CreateWorkspaceServiceAccountToken",
          "grafana:DeleteWorkspaceServiceAccountToken",
          "grafana:ListWorkspaceServiceAccountTokens"
        ]
        Resource = "arn:aws:grafana:${var.region}:*:/workspaces/${var.grafana_workspace_id}/*"
      }
    ]
  })
}

# Policy for Secrets Manager operations
resource "aws_iam_policy" "secretsmanager_policy" {
  name        = "${var.resource_prefix}-grafana-token-rotation-sm-policy"
  description = "Allows Lambda to update Grafana token in Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue",
          "secretsmanager:UpdateSecret"
        ]
        Resource = aws_secretsmanager_secret.grafana_token.arn
      }
    ]
  })
}

# Policy for CloudWatch Logs
resource "aws_iam_policy" "cloudwatch_policy" {
  name        = "${var.resource_prefix}-grafana-token-rotation-cw-policy"
  description = "Allows Lambda to write logs to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Attach policies to role
resource "aws_iam_role_policy_attachment" "grafana_attachment" {
  role       = aws_iam_role.lambda_rotation_role.name
  policy_arn = aws_iam_policy.grafana_policy.arn
}

resource "aws_iam_role_policy_attachment" "secretsmanager_attachment" {
  role       = aws_iam_role.lambda_rotation_role.name
  policy_arn = aws_iam_policy.secretsmanager_policy.arn
}

resource "aws_iam_role_policy_attachment" "cloudwatch_attachment" {
  role       = aws_iam_role.lambda_rotation_role.name
  policy_arn = aws_iam_policy.cloudwatch_policy.arn
}