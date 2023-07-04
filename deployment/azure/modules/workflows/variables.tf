#abfss://container@storageAccount.dfs.core.windows.net
locals {
  adls_storage = "abfss://${var.adls_storage_container}@${var.adls_storage_account}.dfs.core.windows.net"
}

variable "latest_lts" {}
variable "node_type" {}

variable "adls_storage_account" {
}

variable "adls_storage_container" {
}

variable "runtime_engine" {
  description = "enable photon on a cluster"
}

variable "cluster_security_mode" {
  description = "Unity Catalog access mode"
}

variable "data_storage_path"{
  default = "poc-accelerate-data"
  description = "path to source data"
}

variable "catalog_name" {
  description = "name of the catalog"
}

variable "database_name" {
  description = "name of the database"
}

variable "job_email_notification" {
  description = "email address for job notifications"
}

variable "git_pat" {
  description = "Github personal access token"
}

variable "git_user" {
  description = "git user"
}

variable "git_url" {
  description = "url for the git repo"
}

variable "target_database" {
  default = "poc"
}

