# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/synthetics_canary

# attempt to rebuild canary zip file if lambda code changes
locals {
  module_name = "synthetics-canary"
  module_serial_number = "2023072001" # update with each commit?  Date plus two digit increment
  rendered_file_content = templatefile("${path.module}/canary.js.tpl", {
  name            = "zipfile"
  take_screenshot = "true"
  synthetics_canary_url        = var.synthetics_canary_url
  region          = "us-east-1"
  })
  #zip = "${path.module}/lambda_canary-${sha256(local.rendered_file_content)}.zip"
  zip = "${path.module}/lambda_canary.zip"
  // to make sure the canary is redeployed whenever the rendered templated file is modified.
}

data "archive_file" "lambda_canary_zip" {
  type        = "zip"
  output_path = local.zip
  source {
    content  = local.rendered_file_content
    filename = "nodejs/node_modules/pageLoadBlueprint.js"
  }
}

resource "aws_s3_bucket" "canary-output-bucket" {
  count = var.synthetics_canary_create ? 1 : 0
  bucket  = var.synthetics_canary_bucket_name
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }
}

data "aws_iam_policy_document" "canary-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "canary-policy" {
  statement {
    sid     = "CanaryS3Permission1"
    effect  = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets"
    ]
    resources = [
                "${aws_s3_bucket.canary-output-bucket.arn}/*"
    ]
  }

  statement {
    sid     = "CanaryS3Permission2"
    effect  = "Allow"
    actions = [
      "s3:ListAllMyBuckets"
    ]
    resources = [
      "arn:aws:s3:::*"
    ]
  }

  statement {
    sid     = "CanaryCloudWatchLogs"
    effect  = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      #"arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"
      # FIXME: pass region and target_account_id
      "arn:aws:logs:us-east-1:*:log-group:/aws/lambda/*"
    ]
  }

  statement {
    sid     = "CanaryCloudWatchAlarm"
    effect  = "Allow"
    actions = [
      "cloudwatch:PutMetricData"
    ]
    resources = [
      "*"
    ]
    condition {
      test     = "StringEquals"
      values   = ["CloudWatchSynthetics"]
      variable = "cloudwatch:namespace"
    }
  }

}

resource "aws_iam_role" "canary-role" {
  count = var.synthetics_canary_create ? 1 : 0
  name               = "canary-role"
  assume_role_policy = data.aws_iam_policy_document.canary-assume-role-policy.json
  description        = "IAM role for AWS Synthetic Monitoring Canaries"

  tags = {
    ModuleVersion = "${local.module_name}-${local.module_serial_number}" 
  }
}

resource "aws_iam_policy" "canary-policy" {
  count = var.synthetics_canary_create ? 1 : 0
  name        = "canary-policy"
  policy      = data.aws_iam_policy_document.canary-policy.json
  description = "IAM role for AWS Synthetic Monitoring Canaries"

  tags = {
    ModuleVersion = "${local.module_name}-${local.module_serial_number}" 
  }
}

resource "aws_iam_role_policy_attachment" "canary-policy-attachment" {
  count = var.synthetics_canary_create ? 1 : 0
  role       = aws_iam_role.canary-role.name
  policy_arn = aws_iam_policy.canary-policy.arn
}

# provider "aws" {
#   region = "us-east-1"
# }

resource "aws_sns_topic" "topic" {
  count = var.synthetics_canary_create ? 1 : 0
  name = "url_monitoring_topic"
  tags = {
    ModuleVersion = "${local.module_name}-${local.module_serial_number}" 
  }
}

# resource "aws_sns_topic_subscription" "email_subscriptions" {
#   count  = length(var.synthetics_canary_email_addresses)
#   topic_arn = aws_sns_topic.topic.arn
#   protocol  = "email"
#   endpoint  = var.synthetics_canary_email_addresses[count.index]
# }

resource "aws_synthetics_canary" "synthetics_canary_url_monitoring" {
  count = var.synthetics_canary_create ? 1 : 0
  name                       = "canary_monitoring"
  artifact_s3_location = "s3://${aws_s3_bucket.canary-output-bucket.bucket}/"
  execution_role_arn         = aws_iam_role.canary-role.arn
  handler                    = "pageLoadBlueprint.handler"
  zip_file                    = "${path.module}/lambda_canary.zip"
  runtime_version            = "syn-nodejs-puppeteer-4.0"
  start_canary         = true
  schedule {
    expression = "rate(10 minutes)"
  }
  tags = {
    ModuleVersion = "${local.module_name}-${local.module_serial_number}" 
  }
}

resource "aws_cloudwatch_metric_alarm" "canary_alarm" {
  count = var.synthetics_canary_create ? 1 : 0
  alarm_name          = "synthetics_canary_url_monitoring_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "FailedRequests"
  namespace           = "CloudWatchSynthetics"
  period              = "300"
  statistic           = "SampleCount"
  threshold           = "1"
  alarm_description   = "Alarm when URL does not return 200"
  alarm_actions       = [aws_sns_topic.topic.arn]
  dimensions          = {
    #CanaryName = aws_synthetics_canary.synthetics_canary_url_monitoring.name
    CanaryName = "synthetics_canary_url_monitoring"
  }
  tags = {
    ModuleVersion = "${local.module_name}-${local.module_serial_number}" 
  }
}

