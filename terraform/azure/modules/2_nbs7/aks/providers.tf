terraform {
  required_version = ">= 1.13.3"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = ">=2.9.0, <3.0.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.68, <5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }
  }
}