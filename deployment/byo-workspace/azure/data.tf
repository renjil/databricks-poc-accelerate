data "databricks_spark_version" "latest_lts" {
  provider          = databricks.azuredatabricks
  long_term_support = true
  ml = true
}

data "databricks_node_type" "smallest" {
  provider   = databricks.azuredatabricks
  local_disk = true
  photon_driver_capable = true
  photon_worker_capable = true
}