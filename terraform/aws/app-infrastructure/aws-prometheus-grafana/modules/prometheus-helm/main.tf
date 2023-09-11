
resource "helm_release" "prometheus" {
    name = "prometheus"
    repository =  var.repository 
    chart = var.chart 
    dependency_update = var.dependency_update
    lint = var.lint
    force_update = var.force_update 
    values = [
    templatefile(var.values_file_path, { AWS_REGION = "${var.region}", WORKSPACE_ID = "${var.WORKSPACE_ID}", IAM_PROXY_PROMETHEUS_ROLE_ARN = "${var.IAM_PROXY_PROMETHEUS_ROLE_ARN}"})
  ]
    namespace = var.namespace_name
}



