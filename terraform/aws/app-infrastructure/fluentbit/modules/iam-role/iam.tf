locals {
  fluentbit_role_name = "${var.resource_prefix}-fluentbit-role"
}

resource "aws_iam_policy" "fluentbit-policy" {
  name = "${var.resource_prefix}-fluentbit-policy"
  lifecycle {
    create_before_destroy = true
  }
  path        = "/"
  description = "IAM policy for ingestion into Amazon Managed Service for fluentbit"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:PutLogEvents"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role" "fluentbit-role" {
  depends_on = [aws_iam_policy.fluentbit-policy]
  name       = local.fluentbit_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
    "Action": "sts:AssumeRoleWithWebIdentity",
      "Principal": {
    "Federated": "${var.oidc_provider_arn}"
    },
    "Condition": {
    "StringEquals": {
    "${var.oidc_provider}:sub":["system:serviceaccount:${var.service_account_namespace}:${var.service_account_name}"
    ]
    }
    }
    }
  ]
}
EOF
  tags = merge(tomap({ "Name" = "${local.fluentbit_role_name}" }), var.tags)
}

resource "aws_iam_policy_attachment" "test-attach" {
  name       = "${var.resource_prefix}-fluentbit-policy-attachment"
  roles      = [aws_iam_role.fluentbit-role.name]
  policy_arn = aws_iam_policy.fluentbit-policy.arn
}
