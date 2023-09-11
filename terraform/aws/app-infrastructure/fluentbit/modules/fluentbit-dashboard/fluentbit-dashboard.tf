


resource "aws_cloudwatch_dashboard" "dashboards" {
  for_each = toset(var.app_name)
  dashboard_name = "${each.value}-logs-dashboard"
  dashboard_body = templatefile("${path.module}/dashboard.json", {
    log_group_name = var.log_group_name
    pod_name       = "${each.value}*"  
    panel_title    = "${each.value}-pod-logs"
  })
}






  