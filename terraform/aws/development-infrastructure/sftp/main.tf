
resource "aws_s3_bucket" "hl7" {
  bucket = var.bucket_name
}

resource "aws_dynamodb_table" "hl7_errors" {
  name         = "hl7-error-log"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "FileName"

  attribute {
    name = "FileName"
    type = "S"
  }
}

resource "aws_sns_topic" "error" {
  count = var.enable_error_notifications ? 1 : 0
  name  = "hl7-error-notifications"
}

resource "aws_sns_topic" "success" {
  count = var.enable_success_notifications ? 1 : 0
  name  = "hl7-success-notifications"
}

resource "aws_sns_topic" "summary" {
  count = var.enable_summary_notifications ? 1 : 0
  name  = "hl7-summary-notifications"
}

resource "aws_sns_topic_subscription" "error_subs" {
  for_each = var.enable_error_notifications ? toset(var.notification_emails.error) : {}
  topic_arn = aws_sns_topic.error[0].arn
  protocol  = "email"
  endpoint  = each.value
}

resource "aws_sns_topic_subscription" "success_subs" {
  for_each = var.enable_success_notifications ? toset(var.notification_emails.success) : {}
  topic_arn = aws_sns_topic.success[0].arn
  protocol  = "email"
  endpoint  = each.value
}

resource "aws_sns_topic_subscription" "summary_subs" {
  for_each = var.enable_summary_notifications ? toset(var.notification_emails.summary) : {}
  topic_arn = aws_sns_topic.summary[0].arn
  protocol  = "email"
  endpoint  = each.value
}

resource "aws_iam_role" "lambda_exec" {
  name = "hl7-lambda-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          aws_s3_bucket.hl7.arn,
          "${aws_s3_bucket.hl7.arn}/*"
        ],
        Effect = "Allow"
      },
      {
        Action = ["dynamodb:PutItem", "dynamodb:Scan"],
        Effect = "Allow",
        Resource = aws_dynamodb_table.hl7_errors.arn
      },
      {
        Action = ["sns:Publish"],
        Effect = "Allow",
        Resource = concat(
          aws_sns_topic.error[*].arn,
          aws_sns_topic.success[*].arn,
          aws_sns_topic.summary[*].arn
        )
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "hl7_copy" {
  count = var.enable_split_and_validate ? 1 : 0

  filename         = "lambda/copy_to_inbox.zip"
  function_name    = "hl7-copy-to-inbox"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "copy_to_inbox.lambda_handler"
  runtime          = "python3.11"
  source_code_hash = filebase64sha256("lambda/copy_to_inbox.zip")

  environment {
    variables = {
      ERROR_TOPIC_ARN   = try(aws_sns_topic.error[0].arn, "")
      SUCCESS_TOPIC_ARN = try(aws_sns_topic.success[0].arn, "")
    }
  }
}

resource "aws_lambda_function" "hl7_summary" {
  count = var.enable_summary_notifications ? 1 : 0

  filename         = "lambda/summary_report.zip"
  function_name    = "hl7-daily-summary"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "summary_report.lambda_handler"
  runtime          = "python3.11"
  source_code_hash = filebase64sha256("lambda/summary_report.zip")

  environment {
    variables = {
      SUMMARY_TOPIC_ARN = aws_sns_topic.summary[0].arn
    }
  }
}

resource "aws_cloudwatch_event_rule" "summary_schedule" {
  count = var.enable_summary_notifications ? 1 : 0
  name                = "hl7-daily-summary-schedule"
  schedule_expression = var.summary_schedule_expression
}

resource "aws_cloudwatch_event_target" "summary_target" {
  count = var.enable_summary_notifications ? 1 : 0
  rule      = aws_cloudwatch_event_rule.summary_schedule[0].name
  target_id = "hl7-summary-lambda"
  arn       = aws_lambda_function.hl7_summary[0].arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  count = var.enable_summary_notifications ? 1 : 0
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hl7_summary[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.summary_schedule[0].arn
}

