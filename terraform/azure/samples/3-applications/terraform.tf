# NOTE: Please see the commentary in ../0-landing-zone/terraform.tf which is also applicable to this file.

terraform {
  required_version = ">= 1.15.6"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.68, <5.0"
    }
  }

  backend "azurerm" {
    use_azuread_auth = true # Use Microsoft Entra ID authentication

    tenant_id = "EXAMPLE_EXISTING_TENANT_ID"

    storage_account_name = "EXAMPLE_EXISTING_STORAGE_ACCOUNT_NAME"
    container_name       = "EXAMPLE_EXISTING_STORAGE_ACCOUNT_CONTAINER_NAME"
    key                  = "EXAMPLE_BLOB_NAME_TO_CREATE"
  }
}

provider "azurerm" {
  features {}
}

locals {
  environment = "dev1"

  admin_config = yamldecode(data.azurerm_kubernetes_cluster.aks.kube_admin_config_raw)
}

provider "helm" {
  kubernetes = {
    host                   = local.admin_config.clusters[0].cluster.server
    client_certificate     = base64decode(local.admin_config.users[0].user["client-certificate-data"])
    client_key             = base64decode(local.admin_config.users[0].user["client-key-data"])
    cluster_ca_certificate = base64decode(local.admin_config.clusters[0].cluster["certificate-authority-data"])
  }
}
