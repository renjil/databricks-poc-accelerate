variable "spark_version" {}
variable "node_type_id" {}

variable "catalog_name" {
  description = "name of the catalog"
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

variable "git_provider" {
  description = "git provider"
  default = "github"
}

variable "git_branch" {
  description = "git branch"
  default = "main"
}

variable "project_name" {
  description = "name of the project"
}

variable "de_database_name" {
  description = "name of the database"
}

variable "dev_cluster_id" {
  description = "existing cluster id used to run workflows in dev mode. These should be changed to job clusters in production."
}

