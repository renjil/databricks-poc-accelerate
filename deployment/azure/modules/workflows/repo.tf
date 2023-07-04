resource "databricks_repo" "poc_accelerate_repo" {
    url = "https://github.com/renjil/databricks-poc-accelerate"
    git_provider = "gitHub"
}