terraform {
  required_version = ">= 1.13.3"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = ">=2.9.0, <3.0.0"
    }
  }
}