resource "databricks_sql_endpoint" "warehouse" {
  name             = "${var.project_name}_sqlwh"
  cluster_size     = var.sql_cluster_size
  max_num_clusters = 1
  auto_stop_mins   = var.autotermination_minutes
  enable_serverless_compute = true

  tags {
    custom_tags {
      key  = "project"
      value = var.project_name
    }
  }
}