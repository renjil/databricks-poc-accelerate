terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}

# provider "aws" {
#   access_key = var.aws_access_key
#   secret_key = var.aws_secret_key
#   region = var.region
# }

// initialize provider in "MWS" mode to provision new workspace
provider "databricks" {
  alias    = "mws"
  host     = "https://accounts.cloud.databricks.com"
  account_id = var.databricks_account_id
  # auth_type = "basic"
  username = var.databricks_account_username
  password = var.databricks_account_password
}