# data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "fluentbit-policy" {
  name = "fluentbit-policy"
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
  name       = "fluentbit-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "assume-role",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
  "Principal": {
    "Federated": "${var.OIDC_PROVIDER_ARN}"
    }},
    {
      "Sid": "assume-role-web-identity",
      "Effect": "Allow",
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
    "StringEquals": {
    "${var.OIDC_PROVIDER}:sub":["system:serviceaccount:${var.SERVICE_ACCOUNT_NAMESPACE}:${var.SERVICE_ACCOUNT_NAME}"
    ]
    }
    }
    }
  ]
}
EOF
  tags = merge(tomap({ "Name" = "fluentbit-role" }), var.tags)
}

resource "aws_iam_policy_attachment" "test-attach" {
  name       = "fluentbit-policy-attachment"
  roles      = [aws_iam_role.fluentbit-role.name]
  policy_arn = aws_iam_policy.fluentbit-policy.arn
}


# "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.OIDC_PROVIDER}"



