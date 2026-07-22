resource "aws_cloudwatch_event_rule" "rotation_schedule" {
  name                = "${var.resource_prefix}-grafana-token-rotation-schedule"
  description         = "Triggers Grafana token rotation every ${var.rotation_schedule_days} days"
  schedule_expression = "rate(${var.rotation_schedule_days} days)"

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.rotation_schedule.name
  target_id = "GrafanaTokenRotation"
  arn       = aws_lambda_function.token_rotation.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.token_rotation.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rotation_schedule.arn
}