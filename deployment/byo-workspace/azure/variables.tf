variable "workspace_url" {}
variable "workspace_id" {}

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

variable "project_name" {
  description = "name of the project. Use snake_case, no spaces or hyphens allowed."
}

variable "de_database_name" {
  description = "name of the database"
  default = "customer_sales"
}

variable "git_pat" {
  description = "Github personal access token"
}

variable "git_user" {
  description = "git user"
}

variable "git_url" {
  description = "url for the git repo"
  default = "https://github.com/renjil/databricks-poc-accelerate"
}

variable "git_branch" {
  default = "main"
}

variable "git_provider" {
  description = "git provider"
  default = "github"
}

variable "repo_name" {
    default = "databricks-poc-accelerate"
}

variable "job_email_notification" {
  description = "email notification for job success/failures"
}