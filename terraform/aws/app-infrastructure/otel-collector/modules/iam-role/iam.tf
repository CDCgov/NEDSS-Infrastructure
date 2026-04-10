locals {
  otel_role_name = "${var.resource_prefix}-otel-collector-role"
}

resource "aws_iam_policy" "otel_s3_policy" {
  name = "${var.resource_prefix}-otel-collector-s3-policy"
  path = "/"

  lifecycle {
    create_before_destroy = true
  }

  description = "IAM policy for OTEL Collector to write container logs to S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "OtelLogsS3Write"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetBucketLocation"
        ]
        Resource = [
          var.s3_bucket_arn,
          "${var.s3_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "otel_collector_role" {
  depends_on = [aws_iam_policy.otel_s3_policy]
  name       = local.otel_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRoleWithWebIdentity"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${var.oidc_provider}:sub" = "system:serviceaccount:${var.service_account_namespace}:${var.service_account_name}"
            "${var.oidc_provider}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = merge(tomap({ "Name" = local.otel_role_name }), var.tags)
}

resource "aws_iam_policy_attachment" "otel_s3_attachment" {
  name       = "${var.resource_prefix}-otel-collector-policy-attachment"
  roles      = [aws_iam_role.otel_collector_role.name]
  policy_arn = aws_iam_policy.otel_s3_policy.arn
}
