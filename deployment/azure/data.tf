data "databricks_spark_version" "latest_lts" {
  depends_on        = [module.az_workspace]
  long_term_support = true
}

data "databricks_node_type" "smallest" {
  depends_on = [module.az_workspace]
  local_disk = true
}