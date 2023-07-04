output "az_all_purpose_id" {
    value = databricks_cluster.az.id
    description = "POC Accelerate Interactive Cluster"
}

output "sql_warehouse_id" {
  value       = databricks_sql_endpoint.warehouse.data_source_id
  description = "POC Accelerate SQL Warehouse ID"
}
