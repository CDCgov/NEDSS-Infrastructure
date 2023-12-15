
resource "aws_cloudwatch_log_group" "amp_log_group" {
  name = "${var.resource_prefix}-amp-workspace-log-group"
  retention_in_days = var.retention_in_days
  skip_destroy = false
}

resource "aws_prometheus_workspace" "amp_workspace" {
  alias                  = var.alias
  logging_configuration {
  log_group_arn = "${aws_cloudwatch_log_group.amp_log_group.arn}:*"
  }
  tags = merge(tomap({"Name"=var.alias}),var.tags)
}



# Alert Manager Definition
resource "aws_prometheus_alert_manager_definition" "alertmgr_definition" {
  # count = var.create ? 1 : 0
  workspace_id = aws_prometheus_workspace.amp_workspace.id
  # definition   = var.alert_manager_definition
  definition = <<EOF
alertmanager_config: |
  route:
    receiver: 'default'
  receivers:
    - name: 'default'
      sns_configs:
      - topic_arn: ${aws_sns_topic.prometheus-alerts.arn}
        sigv4:
          region: ${var.region}
        attributes:
          key: key1
          value: value1
  EOF
}



# # Rule Group Namespace
resource "aws_prometheus_rule_group_namespace" "amp_rule_group_namespace" {
  name         = "rules"
  workspace_id = aws_prometheus_workspace.amp_workspace.id
  data         = <<EOF
  groups:
  - name: cpu-usage
    rules:
    - record: metric:recording_rule
      expr: avg(rate(container_cpu_usage_seconds_total[5m])) >= 0.004
  
  - name: nginx-requests-per-second
    rules:
    - record: metric:recording_rule
      expr: sum(rate(nginx_ingress_controller_requests[5m])) <= 0.01
EOF
}


resource "aws_sns_topic" "prometheus-alerts" {
  name = "${var.resource_prefix}-amp-workspace-metrics-alerts"
  tags = merge(tomap({"Name"="${var.resource_prefix}-amp-workspace-metrics-alerts"}),var.tags)
}


resource "aws_iam_policy" "sns-policy" {
  name        = "${var.resource_prefix}-amp-workspace-sns-policy"
  lifecycle {
    create_before_destroy = true
  }
  path        = "/"
  description = "IAM policy for Amazon Managed Service Prometheus to send alerts to SNS topic"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { 
  "Effect": "Allow", 
  "Action": [ 
    "sns:Publish", 
    "sns:GetTopicAttributes" 
  ], 
  "Resource": aws_sns_topic.prometheus-alerts.arn 
},
    ]
  })
}



resource "aws_iam_role" "amp_prometheus_role" {
  name = "${var.resource_prefix}-amp-workspace-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
"Principal": {
    "Service": [
        "aps.amazonaws.com"
   ]
}  
    }
  ]
}
EOF

  tags = merge(tomap({"Name"="${var.resource_prefix}-amp-workspace-role"}),var.tags)
}


resource "aws_iam_policy_attachment" "sns-attach" {
  name       = "${var.resource_prefix}-amp-workspace-sns-policy-attachment"
  roles      = [aws_iam_role.amp_prometheus_role.name]
  policy_arn = aws_iam_policy.sns-policy.arn
}

