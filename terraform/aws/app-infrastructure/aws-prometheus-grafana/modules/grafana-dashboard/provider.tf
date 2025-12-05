# #https://registry.terraform.io/providers/grafana/grafana/1.30.0
terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "4.19.0, < 5.0.0"
    }
  }
}

# provider "grafana" {
#   alias = "cloud"
#   url   = var.grafana_workspace_url
#   auth  = var.amg_api_token #grafana_service_account_token.admin-sa-token.key #
# }