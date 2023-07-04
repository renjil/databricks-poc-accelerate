resource "databricks_directory" "shared_dir" {
  path = "/Shared/Queries/Poc_Accelerate"
}

resource "databricks_sql_query" "poc_accl_sales_per_product_group" {
  data_source_id = var.sql_warehouse_data_source_id
  name           = "PocAcclerate - Sales per product group"
  query          = <<EOT
SELECT * FROM renjiharold_demo.poc.product_group_txn_amount_gold
                    EOT

  parent      = "folders/${databricks_directory.shared_dir.object_id}"
  run_as_role = "owner"

  tags = [
    "poc-accelerate"
  ]
}

resource "databricks_sql_query" "poc_accl_total_revenue" {
  data_source_id = var.sql_warehouse_data_source_id
  name           = "PocAcclerate - Total Revenue"
  query          = <<EOT
  SELECT * FROM renjiharold_demo.poc.total_revenue_gold
                    EOT

  parent      = "folders/${databricks_directory.shared_dir.object_id}"
  run_as_role = "owner"

  tags = [
    "poc-accelerate"
  ]
}

resource "databricks_sql_query" "poc_accl_cust_traffic_per_store" {
  data_source_id = var.sql_warehouse_data_source_id
  name           = "PocAcclerate - Customer Traffic per store"
  query          = <<EOT
SELECT * FROM renjiharold_demo.poc.top_store_traffic_gold
                    EOT

  parent      = "folders/${databricks_directory.shared_dir.object_id}"
  run_as_role = "owner"

  tags = [
    "poc-accelerate"
  ]
}

resource "databricks_sql_query" "poc_accl_list_of_stores" {
  data_source_id = var.sql_warehouse_data_source_id
  name           = "PocAcclerate - List of Stores"
  query          = <<EOT
select distinct store_name from renjiharold_demo.poc.store_silver
                    EOT

  parent      = "folders/${databricks_directory.shared_dir.object_id}"
  run_as_role = "owner"

  tags = [
    "poc-accelerate"
  ]
}

resource "databricks_sql_query" "poc_accl_dummy" {
  data_source_id = var.sql_warehouse_data_source_id
  name           = "PocAcclerate - Dummy Query"
  query          = <<EOT
select distinct store_name from jibberish.apoc.astore_silver
                    EOT

  parent      = "folders/${databricks_directory.shared_dir.object_id}"
  run_as_role = "owner"

  tags = [
    "poc-accelerate"
  ]
}



resource "databricks_sql_query" "poc_accl_sales_analysis_per_store" {
  data_source_id = var.sql_warehouse_data_source_id
  name           = "PocAcclerate - Sales Analysis per store"
  query          = <<EOT
select store_name, transaction_date, transaction_amount from 
renjiharold_demo.poc.sales_silver sales
left join 
renjiharold_demo.poc.store_silver store
on sales.store_code = store.store_id
where store_name == '{{ store_name }}'
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
    "poc-accelerate"
  ]
}


