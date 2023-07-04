variable "databricks_host" {}
variable "workspace_id" {}
variable "latest_lts" {}
variable "node_type" {}

variable "cluster_name" {
  default = "POC Accelerate Interactive"
}

variable "cluster_security_mode" {
  default = "SINGLE_USER"
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

variable "sql_warehouse_name" {
  default = "poc-accelerate-sqlwh"
}

variable "sql_cluster_size" {
  default = "2X-Small"
}