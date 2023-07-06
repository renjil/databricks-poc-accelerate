resource "databricks_repo" "poc_accelerate_repo" {
    url = var.git_url
    git_provider = var.git_provider
    path = "/Repos/${data.databricks_current_user.me.user_name}/${var.project_name}" 
    branch = var.git_branch
}