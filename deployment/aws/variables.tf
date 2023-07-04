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

variable "db_host" {
  default = null
}
variable "db_token" {
  default = null
}

variable "metastore_storage_label" {
  default = "uc"
} 
variable "metastore_name" {
  default = "poc_accelerate_metastore"
}
variable "metastore_label" {
  default = "metastore"
}

variable "runtime_engine" {
  default = "PHOTON"
}

variable "cluster_security_mode" {
  default = "SINGLE_USER"
  description = "Unity Catalog access mode"
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

variable "node_type_id" {
  default = "i3.xlarge"
}

variable "data_storage_path"{
  default = "poc-accelerate-data"
  description = "path to source data"
}

variable "project_name" {
  description = "name of the project. Use snake_case, no spaces or hyphens allowed."
}

variable "de_database_name" {
  description = "name of the database"
  default = "customer_sales"
}

# variable "git_pat" {
#   description = "Github personal access token"
# }

# variable "git_user" {
#   description = "git user"
# }

variable "git_url" {
  description = "url for the git repo"
}

variable "git_branch" {
  default = "main"
}

variable "git_provider" {
  description = "git provider"
  default = "github"
}

variable "repo_name" {
    default = "anzmmc-packaged-poc"
}
