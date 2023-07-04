variable "databricks_account_username" {}
variable "git_user" {}
variable "git_pat" {}

variable "runtime_engine" {
  default = "PHOTON"
}

variable "autotermination_minutes" {
  default = 20
}

variable "min_workers" {
  default = 1
}

variable "max_workers" {
  default = 2
}

variable "cluster_security_mode" {
  default     = "SINGLE_USER"
  description = "Unity Catalog access mode"
}

variable "sql_cluster_size" {
  default = "2X-Small"
}

variable "data_storage_path" {
  default = "poc-accelerate-data"
}

variable "catalog_name" {
  default = "poc_accelerate"
}

variable "database_name" {
  default = "synthetic_db"
}

variable "job_email_notification" {
  default = "brendan.forbes@databricks.com"
}

variable "git_url" {
  default = "https://github.com/databricks/anzmmc-packaged-poc"
}

