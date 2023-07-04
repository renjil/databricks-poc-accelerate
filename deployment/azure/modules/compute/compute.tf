

resource "databricks_cluster" "az" {
  cluster_name            = var.cluster_name
  spark_version           = var.latest_lts
  node_type_id            = var.node_type
  autotermination_minutes = var.autotermination_minutes
  data_security_mode      = var.cluster_security_mode
  autoscale {
    min_workers = var.min_workers
    max_workers = var.max_workers
  }
  custom_tags = {
    "project" = "poc-accelerate"
  }
}


resource "databricks_sql_endpoint" "warehouse" {
  name             = var.sql_warehouse_name
  cluster_size     = var.sql_cluster_size
  max_num_clusters = 1
  auto_stop_mins = var.autotermination_minutes

  tags {
    custom_tags {
      key   = "project"
      value = "poc-accelerate"
    }
  }
}