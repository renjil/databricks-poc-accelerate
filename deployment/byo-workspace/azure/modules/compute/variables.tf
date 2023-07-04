variable "spark_version" {}
variable "node_type_id" {}

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

variable "sql_cluster_size" {
  default = "2X-Small"
}

variable "project_name" {
  description = "name of the project"
}

variable "tags" {
  description = "tags to apply to resources"
  default = {}
}