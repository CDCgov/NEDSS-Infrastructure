terraform {
  # Reference info: https://developer.hashicorp.com/terraform/language/block/terraform#required_version
  required_version = ">= 1.13.3"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.68, <5.0"
    }
  }

  # The following 'backend' block specifies where to store the Terraform state file for this directory (i.e. this layer of Terraform).
  # Reference info: https://developer.hashicorp.com/terraform/language/block/terraform#backend and https://developer.hashicorp.com/terraform/language/backend/azurerm
  backend "azurerm" {
    # As described within https://cdcgov.github.io/NEDSS-SystemAdminGuide/docs/deploy-nbs7/deploy-on-azure.html , in your own copy of this code replace
    # each "EXAMPLE_*" string below with information for your Azure subscription.

    use_azuread_auth = true # Use Microsoft Entra ID authentication

    # This is specified in the Microsoft Azure portal by the "Microsoft Entra ID" service:
    tenant_id = "EXAMPLE_EXISTING_TENANT_ID"

    # Note that the storage account and container below must already exist in your Azure subscription.

    # The name of the storage account In Azure portal in the "Storage accounts" service, e.g. "nbs7-environments"
    storage_account_name = "EXAMPLE_EXISTING_STORAGE_ACCOUNT_NAME"
    # The name of the container in the storage account, e.g. "tfstate"
    container_name = "EXAMPLE_EXISTING_STORAGE_ACCOUNT_CONTAINER_NAME"
    # The blob (directory path and filename) within the storage account's container that Terraform will write its state to, e.g. "<environment-name>/<tf-layer>.tfstate" where <tf-layer> is the name of the current directory.
    key = "EXAMPLE_BLOB_NAME_TO_CREATE"
  }
}

provider "azurerm" {
  features {}
}
