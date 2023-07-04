# resource "databricks_git_credential" "poc_accl_git" {
#   personal_access_token = var.git_pat
#   git_username          = var.git_user
#   git_provider          = var.git_provider
# }

resource "databricks_repo" "poc_accelerate_repo" {
    url = var.git_url
    git_provider = var.git_provider
    path = "/Repos/${data.databricks_current_user.me.user_name}/${var.project_name}" 
    branch = var.git_branch
}