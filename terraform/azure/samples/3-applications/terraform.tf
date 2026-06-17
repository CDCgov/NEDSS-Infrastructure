locals {
  admin_config = yamldecode(data.azurerm_kubernetes_cluster.aks.kube_admin_config_raw)
}

terraform {
  required_version = ">= 1.13.3"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.68, <5.0"
    }
  }

  backend "azurerm" {
    use_azuread_auth     = true
    tenant_id            = ""
    storage_account_name = ""
    container_name       = ""
    key                  = "/0-landing-zone.tfstate"
  }
}

locals {
  environment = "dev1"
}

provider "azurerm" {
  features {}
}

provider "helm" {
  kubernetes = {
    host                   = local.admin_config.clusters[0].cluster.server
    client_certificate     = base64decode(local.admin_config.users[0].user["client-certificate-data"])
    client_key             = base64decode(local.admin_config.users[0].user["client-key-data"])
    cluster_ca_certificate = base64decode(local.admin_config.clusters[0].cluster["certificate-authority-data"])
  }
}
