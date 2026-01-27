resource "aws_grafana_workspace" "amg" {
  name                     = var.grafana_workspace_name
  account_access_type      = "CURRENT_ACCOUNT"
  authentication_providers = ["AWS_SSO"]
  permission_type          = "SERVICE_MANAGED"
  role_arn                 = aws_iam_role.grafana_role.arn
  data_sources             = var.data_sources
  tags                     = var.tags
}

resource "aws_iam_policy" "policy" {
  name = "${var.resource_prefix}-amg-policy"
  lifecycle {
    create_before_destroy = true
  }
  path        = "/"
  description = "IAM policy for ingestion into Amazon Managed Service for Grafana"
  policy = jsonencode({
    Version = "2012-10-17"
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "aps:ListWorkspaces",
          "aps:DescribeWorkspace",
          "aps:QueryMetrics",
          "aps:GetLabels",
          "aps:GetSeries",
          "aps:GetMetricMetadata"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role" "grafana_role" {
  name = "${var.resource_prefix}-amg-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "grafana.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "grafana-attach" {
  name       = "${var.resource_prefix}-amg-policy-attachment"
  roles      = [aws_iam_role.grafana_role.name]
  policy_arn = aws_iam_policy.policy.arn
}

######################################
# Service Account (replaces deprecated API key)
# Token rotation is handled by Lambda + Secrets Manager
######################################

resource "aws_grafana_workspace_service_account" "terraform_sa" {
  name         = "${var.resource_prefix}-terraform-sa"
  grafana_role = "ADMIN"
  workspace_id = aws_grafana_workspace.amg.id
}

# NOTE: The following resources have been REMOVED:
# - locals { expiration_days, expiration_seconds }
# - resource "time_rotating" "rotate"
# - resource "time_static" "rotate"  
# - resource "aws_grafana_workspace_api_key" "api_key"
#
# Token creation and rotation is now handled by the grafana-token-rotation Lambda module