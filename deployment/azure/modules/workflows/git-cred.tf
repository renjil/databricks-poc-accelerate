resource "databricks_git_credential" "poc_accl_git" {
  personal_access_token = var.git_pat
  git_username          = var.git_user
  git_provider          = "gitHub"
}