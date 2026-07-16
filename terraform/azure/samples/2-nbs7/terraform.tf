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
