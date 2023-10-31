

resource "aws_iam_policy" "policy" {
  name        = "prometheus-policy"
  lifecycle {
    create_before_destroy = true
  }
  path        = "/"
  description = "IAM policy for ingestion into Amazon Managed Service for Prometheus"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
            "aps:RemoteWrite",
            "aps:GetSeries",
            "aps:GetLabels",
            "aps:GetMetricMetadata"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role" "prommetheus_role" {
  name = "prometheus_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
  "Principal": {
    "Federated": "${var.OIDC_PROVIDER_ARN}"
    },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
    "StringEquals": {
    "${var.OIDC_PROVIDER}:sub":["system:serviceaccount:${var.SERVICE_ACCOUNT_NAMESPACE}:${var.SERVICE_ACCOUNT_AMP_INGEST_NAME}"
    ]
    }
    }
    }
  ]
}
EOF

  tags = merge(tomap({"Name"="prometheus_role"}),var.tags)
}



resource "aws_iam_policy_attachment" "prometheus-attach" {
  name       = "prometheus-policy-attachment"
  roles      = [aws_iam_role.prommetheus_role.name]
  policy_arn = aws_iam_policy.policy.arn
}




