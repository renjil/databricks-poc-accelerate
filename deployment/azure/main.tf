module "az_workspace" {
  providers = {
    azurerm    = azurerm
    databricks = databricks.azure_account
  }
  source                      = "./modules/az_workspace"
  databricks_account_username = var.databricks_account_username
}


module "az_compute" {
  source = "./modules/compute"
  providers = {
    azurerm    = azurerm
    databricks = databricks.azuredatabricks
  }
  autotermination_minutes = var.autotermination_minutes
  cluster_security_mode   = var.cluster_security_mode
  latest_lts              = data.databricks_spark_version.latest_lts.id
  node_type               = data.databricks_node_type.smallest.id
  min_workers             = var.min_workers
  max_workers             = var.max_workers
  sql_cluster_size        = var.sql_cluster_size
  databricks_host         = module.az_workspace.databricks_host
  workspace_id            = module.az_workspace.databricks_workspace_id
}



module "jobs" {
  source = "./modules/workflows"
  providers = {
    azurerm    = azurerm
    databricks = databricks.azuredatabricks
  }
  runtime_engine         = var.runtime_engine
  latest_lts             = data.databricks_spark_version.latest_lts.id
  node_type              = data.databricks_node_type.smallest.id
  catalog_name           = var.catalog_name
  database_name          = var.database_name
  adls_storage_account   = module.az_workspace.adls_storage_account
  adls_storage_container = module.az_workspace.adls_storage_container
  job_email_notification = var.job_email_notification
  cluster_security_mode  = var.cluster_security_mode
  git_url                = var.git_url
  git_user               = var.git_user
  git_pat                = var.git_pat
}



module "queries" {
  source = "./modules/queries"
  providers = {
    azurerm    = azurerm
    databricks = databricks.azure_account
  }

  sql_warehouse_data_source_id = module.az_compute.sql_warehouse_id
  databricks_host              = module.az_workspace.databricks_host
  workspace_id                 = module.az_workspace.databricks_workspace_id
}

