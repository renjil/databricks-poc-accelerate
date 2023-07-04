resource "databricks_repo" "poc_accelerate_repo" {
    url = "https://github.com/databricks/anzmmc-packaged-poc"
    git_provider = "gitHub"
}