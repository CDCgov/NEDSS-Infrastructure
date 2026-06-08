# Scheduled EventBridge rule - runs every Monday at 01:00 UTC
resource "aws_cloudwatch_event_rule" "weekly_lambda" {
  name                = "${var.resource_prefix}-weekly-lambda-trigger"
  description         = "Trigger Lambda  week"
  schedule_expression = var.schedule_cron_expression
}

# Permission for EventBridge to invoke Lambda
resource "aws_lambda_permission" "allow_weekly_event" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.weekly_lambda.arn
}

# Target the Lambda function
resource "aws_cloudwatch_event_target" "weekly_lambda_target" {
  rule      = aws_cloudwatch_event_rule.weekly_lambda.name
  target_id = "lambda"
  arn       = aws_lambda_function.this.arn
}