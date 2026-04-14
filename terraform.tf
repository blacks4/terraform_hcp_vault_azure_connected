terraform {
  required_version = ">= 1.14.8"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.67"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.8"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.111"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
}

provider "azuread" {
  tenant_id     = var.azure_tenant_id
  client_id     = var.azure_client_id
  client_secret = var.azure_client_secret
}

provider "hcp" {
  client_id     = var.hcp_client_id
  client_secret = var.hcp_client_secret
  project_id    = var.hcp_project_id
}
