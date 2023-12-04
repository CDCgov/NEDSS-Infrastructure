

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

resource "aws_iam_role" "prometheus_role" {
  name = "prometheus-role"
  lifecycle {
    create_before_destroy = true
  }

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
  "Principal": {
    "Federated": "${var.oidc_provider_arn}"
    },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
    "StringEquals": {
    "${var.oidc_provider}:sub":["system:serviceaccount:${var.service_account_namespace}:${var.service_account_amp_ingest_name}"
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
  name       = "prometheus-policy-att"
  lifecycle {
    create_before_destroy = true
  }
  roles      = [aws_iam_role.prometheus_role.name]
  policy_arn = aws_iam_policy.policy.arn
}




