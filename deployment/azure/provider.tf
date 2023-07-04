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
  host                        = module.az_workspace.databricks_host
  azure_workspace_resource_id = module.az_workspace.databricks_workspace_id
}
