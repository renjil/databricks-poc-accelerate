resource "random_pet" "this" {
  length    = 2
  separator = "_"
}

module "workflows" {
  source                 = "./modules/workflows"
  providers = {
    databricks = databricks.databricks
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

  db_host = var.db_host
  db_token = var.db_token

}

module "compute" {
  source = "./modules/compute"

  project_name                 = "${var.project_name}_${random_pet.this.id}"

  autotermination_minutes      = var.autotermination_minutes
  tags                         = tomap({"project" = var.project_name}) 

  sql_cluster_size             = var.sql_cluster_size
  db_host                      = var.db_host
  db_token                     = var.db_token
}

module "queries" {
  source = "./modules/queries"

  project_name                 = "${var.project_name}_${random_pet.this.id}"

  sql_warehouse_data_source_id = module.compute.sql_warehouse_id
  catalog_name                 = "${var.project_name}_${random_pet.this.id}_catalog"
  de_database_name             = var.de_database_name
  db_host                      = var.db_host
  db_token                     = var.db_token
}




