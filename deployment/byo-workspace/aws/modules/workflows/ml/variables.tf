variable "existing_cluster_id" {
  description = "existing cluster id"
}

variable "tags" {
  description = "tags to apply to resources"
}

variable "experiment_dir_path" {
}

# variable "git_provider" {
#   description = "git provider"
#   default = "github"
# }

# variable "git_url" {
#   description = "url for the git repo"
# }

# variable "git_branch" {
#   description = "git branch"
#   default = "main"
# }

# variable "git_user" {
#   description = "git user"
# }

# variable "git_pat" {
#   description = "Github personal access token"
# }

variable "job_email_notification" {
    description = "email address for job notifications"
}

variable "catalog_name" {
  description = "name of the catalog to use for data storage"
}

variable "repo_path" {
  description = "path to the repo"
}

variable "project_name" {
  description = "name of the project"
}
