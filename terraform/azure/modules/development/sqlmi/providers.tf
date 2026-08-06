terraform {
  required_version = ">= 1.15.6"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.68, <5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.9.0, <4.0.0"
    }

  }
}
