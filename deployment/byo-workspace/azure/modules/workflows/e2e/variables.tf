variable "node_type_id" {}

variable "existing_cluster_id" {
  description = "existing cluster id"
}

variable "tags" {
  description = "tags to apply to resources"
}

variable "git_provider" {
  description = "git provider"
  default = "github"
}

variable "git_branch" {
  description = "git branch"
  default = "main"
}

variable "git_url" {
  description = "url for the git repo"
}

variable "git_user" {
  description = "git user"
}

variable "git_pat" {
  description = "Github personal access token"
}

variable "repo_path" {
  description = "path to the repo"
}

variable "data_storage_path"{
  default = "poc-accelerate-data"
  description = "path to source data"
}

variable "de_database_name" {
  description = "name of the database"
}

variable "runtime_engine" {
  description = "enable photon on a cluster"
}

variable "cluster_security_mode" {
  description = "Unity Catalog access mode"
}

variable "job_email_notification" {
  description = "email address for job notifications"
}

variable "catalog_name" {
  description = "name of the catalog to use for data storage"
}

variable "project_name" {
  description = "name of the project"
}

variable "experiment_dir_path" {
}