terraform {
  required_version = ">= 1.13.3"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.68, <5.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">=3.1.1"
    }
  }
}
