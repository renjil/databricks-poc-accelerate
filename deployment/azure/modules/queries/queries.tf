resource "databricks_directory" "shared_dir" {
  path = "/Shared/Queries/${var.project_name}"
}

resource "databricks_sql_query" "poc_accl_sales_per_product_group" {
  data_source_id = var.sql_warehouse_data_source_id
  name           = "${var.project_name} - Sales per product group"
  query          = <<EOT
SELECT * FROM ${var.catalog_name}.${var.de_database_name}.product_group_txn_amount_gold
                    EOT

  parent      = "folders/${databricks_directory.shared_dir.object_id}"
  run_as_role = "owner"

  tags = [
    var.project_name
  ]
}

resource "databricks_sql_query" "poc_accl_total_revenue" {
  data_source_id = var.sql_warehouse_data_source_id
  name           = "${var.project_name} - Total Revenue"
  query          = <<EOT
  SELECT * FROM ${var.catalog_name}.${var.de_database_name}.total_revenue_gold
                    EOT

  parent      = "folders/${databricks_directory.shared_dir.object_id}"
  run_as_role = "owner"

  tags = [
    var.project_name
  ]
}

resource "databricks_sql_query" "poc_accl_cust_traffic_per_store" {
  data_source_id = var.sql_warehouse_data_source_id
  name           = "${var.project_name} - Customer Traffic per store"
  query          = <<EOT
SELECT * FROM ${var.catalog_name}.${var.de_database_name}.top_store_traffic_gold
                    EOT

  parent      = "folders/${databricks_directory.shared_dir.object_id}"
  run_as_role = "owner"

  tags = [
    var.project_name
  ]
}

resource "databricks_sql_query" "poc_accl_list_of_stores" {
  data_source_id = var.sql_warehouse_data_source_id
  name           = "${var.project_name} - List of Stores"
  query          = <<EOT
select distinct store_name from ${var.catalog_name}.${var.de_database_name}.store_silver
                    EOT

  parent      = "folders/${databricks_directory.shared_dir.object_id}"
  run_as_role = "owner"

  tags = [
    var.project_name
  ]
}

resource "databricks_sql_query" "poc_accl_sales_analysis_per_store" {
  data_source_id = var.sql_warehouse_data_source_id
  name           = "${var.project_name} - Sales Analysis per store"
  query          = <<EOT
select store_name, transaction_date, transaction_amount from 
${var.catalog_name}.${var.de_database_name}.sales_silver sales
left join 
${var.catalog_name}.${var.de_database_name}.store_silver store
on sales.store_code = store.store_id
where store_name = '{{store_name}}'
                    EOT
  
  parameter {
    name  = "store_name"
    title = "Store name"
    text {
      value = "default"
    }
  }

  parent      = "folders/${databricks_directory.shared_dir.object_id}"
  run_as_role = "owner"

  tags = [
    var.project_name
  ]
}


