# resource "grafana_service_account" "admin-sa" {
#   name        = "admin-service-account"
#   role        = "Admin"
#   is_disabled = false
# }

# resource "grafana_service_account_token" "admin-sa-token" {
#   name               = "admin-service-account-token"
#   service_account_id = grafana_service_account.admin-sa.id
#   seconds_to_live    = 200000
# }

# output "service_account_token_key_only" {
#   value     = grafana_service_account_token.admin-sa-token.key
#   sensitive = true
# }

###########

#https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/folder
resource "grafana_folder" "data" {
  provider = grafana.cloud
  title = "prometheus-nginx-ingress-controller"
}


resource "grafana_data_source" "prometheus" {
  provider = grafana.cloud
  type                = "prometheus"
  name                = "aws-prometheus"
  url                 = var.amp_url #"https://my-instances.com"
  # basic_auth_enabled  = true
  basic_auth_username = "username"
  uid = "prom_ds_uid"

  json_data_encoded = jsonencode({
    httpMethod        = "GET"
    # prometheusType    = "Mimir"
    # prometheusVersion = "2.4.0"
    sigV4Auth = true
    sigV4AuthType = "ec2_iam_role"
    sigV4Region = "us-east-1"
    provisionedBy = "aws-datasource-provisioner-app"
    readOnly = false

  })
  secure_json_data_encoded = jsonencode({
    basicAuthPassword = "password"
  })
}

#https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/dashboard
resource "grafana_dashboard" "prometheus-nginx-ingress-controller" {
  provider = grafana.cloud
  config_json = file("${path.module}/grafana-dashboard.json")    # file("./dashboard/NGINX-Ingress-controller.json")
  folder = grafana_folder.data.id
  overwrite = true
}