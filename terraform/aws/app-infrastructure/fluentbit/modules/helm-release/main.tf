locals {
  values_file_path = "${var.path_to_fluentbit}/modules/helm-release/values.yaml"
}


data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_log_group" "fluentbit-logsgroup" {
  name              = var.fluentbit_cwlogsgroup_name
  retention_in_days = var.retention_in_days
}

resource "helm_release" "fluentbit" {
  provider   = helm
  name       = var.release_name
  depends_on = [aws_cloudwatch_log_group.fluentbit-logsgroup]
  repository = var.repository
  chart      = var.chart
  values = [
    templatefile(local.values_file_path, { AWS_REGION = "${data.aws_caller_identity.current.account_id}", FLUENTBIT_ROLE_ARN = "${var.fluentbit_role_arn}", bucket = "${var.bucket}", SERVICE_ACCOUNT_NAME = "${var.service_account_name}", fluentbit_cwlogsgroup_name = "${var.fluentbit_cwlogsgroup_name}" })
  ]
  namespace        = var.namespace
  create_namespace = true
}



 