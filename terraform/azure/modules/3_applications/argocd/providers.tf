terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }

    helm = {
      source = "hashicorp/helm"
      version = "~>2.12"
    }
  }
}
