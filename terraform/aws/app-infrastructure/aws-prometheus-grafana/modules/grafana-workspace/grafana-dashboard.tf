# #https://registry.terraform.io/providers/grafana/grafana/1.30.0
terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "2.1.0"
    }
  }
}

provider "grafana" {
  alias = "cloud"
  url   = "https://${module.grafana-workspace.amg-workspace_endpoint}"
  auth  = aws_grafana_workspace_api_key.api_key.key #grafana_service_account_token.admin-sa-token.key #
}

###########

#https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/folder
resource "grafana_folder" "data" {
  provider = grafana.cloud
  title    = "prometheus-nginx-ingress-controller"
}


resource "grafana_data_source" "prometheus" {
  provider = grafana.cloud
  type     = "prometheus"
  name     = "aws-prometheus"
  url      = module.prometheus-workspace.amp_workspace_endpoint #"https://my-instances.com"
  # basic_auth_enabled  = true
  basic_auth_username = "username"
  uid                 = "prom_ds_uid"

  json_data_encoded = jsonencode({
    httpMethod = "GET"
    # prometheusType    = "Mimir"
    # prometheusVersion = "2.4.0"
    sigV4Auth     = true
    sigV4AuthType = "ec2_iam_role"
    sigV4Region   = var.region
    provisionedBy = "aws-datasource-provisioner-app"
    readOnly      = false

  })
  secure_json_data_encoded = jsonencode({
    basicAuthPassword = "password"
  })
}

#https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/dashboard
resource "grafana_dashboard" "prometheus-nginx-ingress-controller" {
  provider    = grafana.cloud
  config_json = file("${path.module}/grafana-dashboard.json") # file("./dashboard/NGINX-Ingress-controller.json")
  folder      = grafana_folder.data.id
  overwrite   = true
}