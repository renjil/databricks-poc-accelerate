terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.61.0"
    }
  }
}

provider "azurerm" {
  features {}
  #skip_provider_registration = true
}

// Provider for databricks account
provider "databricks" {
  alias     = "azure_account"
  host      = "https://accounts.azuredatabricks.net"
  auth_type = "azure-cli"
}

provider "databricks" {
  alias                       = "azuredatabricks"
  host                        = var.workspace_url
  azure_workspace_resource_id = var.workspace_id
}
