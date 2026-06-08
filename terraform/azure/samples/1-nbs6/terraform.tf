terraform {
  required_version = ">=1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.68, <5.0"
    }
  }
}

provider "azurerm" {
  features {}
}
