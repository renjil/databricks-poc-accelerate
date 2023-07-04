resource "random_pet" "this" {
  length    = 2
  separator = "_"
}

module "workflows" {
  source = "./modules/workflows"
  providers = {
    azurerm    = azurerm
    databricks = databricks.azuredatabricks
  }

  project_name           = "${var.project_name}_${random_pet.this.id}"
  # DE specific
  de_database_name       = var.de_database_name
  
  # Dev cluster specific
  catalog_name           = "${var.project_name}_${random_pet.this.id}_catalog"

  # Generally applicable
  dev_cluster_id         = module.compute.all_purpose_id
  git_pat                = var.git_pat
  git_user               = var.git_user
  git_url                = var.git_url
  git_branch             = var.git_branch 
  git_provider           = var.git_provider
  spark_version          = data.databricks_spark_version.latest_lts.id
  node_type_id           = data.databricks_node_type.smallest
}

module "compute" {
  source = "./modules/compute"
  providers = {
    databricks = databricks.azuredatabricks
  }
  project_name                 = "${var.project_name}_${random_pet.this.id}"

  autotermination_minutes      = var.autotermination_minutes
  tags                         = tomap({"project" = var.project_name}) 
  spark_version          = data.databricks_spark_version.latest_lts.id
  node_type_id           = data.databricks_node_type.smallest.id
  sql_cluster_size             = var.sql_cluster_size
}

module "queries" {
  source = "./modules/queries"
  providers = {
    databricks = databricks.azuredatabricks
  }

  project_name                 = "${var.project_name}_${random_pet.this.id}"
  sql_warehouse_data_source_id = module.compute.sql_warehouse_id
  catalog_name                 = "${var.project_name}_${random_pet.this.id}_catalog"
  de_database_name             = var.de_database_name
}