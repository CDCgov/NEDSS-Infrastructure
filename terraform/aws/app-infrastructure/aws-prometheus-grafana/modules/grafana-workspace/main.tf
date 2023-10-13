resource "aws_grafana_workspace" "amg" {
  name = var.grafana_workspace_name
  account_access_type      = "CURRENT_ACCOUNT"
  authentication_providers = ["AWS_SSO"]
  permission_type          = "SERVICE_MANAGED"
  role_arn                 = aws_iam_role.grafana_role.arn
  data_sources = var.data_sources
  tags = var.tags
}

resource "aws_iam_policy" "policy" {
  name        = "grafana-policy"
  lifecycle {
    create_before_destroy = true
  }
  path        = "/"
  description = "IAM policy for ingestion into Amazon Managed Service for Grafana"
  policy = jsonencode({
    Version = "2012-10-17"
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "aps:ListWorkspaces",
                "aps:DescribeWorkspace",
                "aps:QueryMetrics",
                "aps:GetLabels",
                "aps:GetSeries",
                "aps:GetMetricMetadata"
            ],
            "Resource": "*"
        }
    ]
  })
}

resource "aws_iam_role" "grafana_role" {
  name = "grafana-role"
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
  name       = "grafana-policy-attachment"
  roles      = [aws_iam_role.grafana_role.name]
  policy_arn = aws_iam_policy.policy.arn
}

##########################################
# https://github.com/hashicorp/terraform-provider-aws/issues/27043
locals {
  expiration_days    = 30
  expiration_seconds = 60 * 60 * 24 * local.expiration_days
}

resource "time_rotating" "rotate" {
  rotation_days = local.expiration_days
}

resource "time_static" "rotate" {
  rfc3339 = time_rotating.rotate.rfc3339
}
#########################################

resource "aws_grafana_workspace_api_key" "api_key" {
  key_name        = "amg_api_key"
  key_role        = "ADMIN"
  seconds_to_live = local.expiration_seconds #2592000 # 3600
  workspace_id    = aws_grafana_workspace.amg.id
  lifecycle {
    replace_triggered_by = [
      time_static.rotate
    ]
  }
}
