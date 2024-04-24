
resource "helm_release" "prometheus" {
    name = "prometheus"
    repository =  var.repository 
    chart = var.chart 
    dependency_update = var.dependency_update
    lint = var.lint
    force_update = var.force_update 
    values = [
    templatefile(var.values_file_path, { AWS_REGION = "${var.region}", WORKSPACE_ID = "${var.workspace_id}", IAM_PROXY_PROMETHEUS_ROLE_ARN = "${var.iam_proxy_prometheus_role_arn}", SERVICE_ACCOUNT_NAME = "${var.service_account_amp_ingest_name}"})
  ]
    namespace = var.namespace_name
    create_namespace = true
}



