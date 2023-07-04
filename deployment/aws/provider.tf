terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "< 5.0"
    }
  }
}

provider "aws" {
  region = var.region
#   profile = "default"
  # Use env variables for AWS creds if aws cli is not installed
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "databricks" {
    alias = "databricks"
    # use db cli profile if configured
    # profile = "db-aws"
    # else use pat token or username/password
    host = module.aws_ws.databricks_host
    token = module.aws_ws.databricks_token
}