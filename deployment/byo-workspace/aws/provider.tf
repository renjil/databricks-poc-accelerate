terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}


 provider "databricks" {
    alias = "databricks"
    host = var.db_host
    token = var.db_token
 }