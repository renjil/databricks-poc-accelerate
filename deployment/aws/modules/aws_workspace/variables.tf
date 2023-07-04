variable "databricks_account_username" {}
variable "databricks_account_password" {}
variable "databricks_account_id" {}

variable "tags" {
  default = {}
}

variable "cidr_block" {
  default = "10.4.0.0/16"
}

variable "region" {
  default = "ap-southeast-2"
}

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_account_id" {}

variable "metastore_storage_label" {}
variable "metastore_name" {}
variable "metastore_label" {}
# variable "metastore_id" {}
# variable "default_metastore_workspace_id" {}
# variable "default_metastore_default_catalog_name" {}

resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

locals {
  prefix = "poc-accelerate-${random_string.naming.result}"
  tags = {
    owner = "john.doe@org.com"
    env = "dev"
  }
}