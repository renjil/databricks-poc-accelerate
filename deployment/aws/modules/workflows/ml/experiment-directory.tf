resource "databricks_directory" "experiments_dir" {
  path = var.experiment_dir_path
}
