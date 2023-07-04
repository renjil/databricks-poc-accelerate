resource "random_pet" "this" {
  length    = 2
  separator = "_"
}

module "aws_ws" {
  source = "./modules/aws_workspace"
  
  databricks_account_id       = var.databricks_account_id
  databricks_account_username = var.databricks_account_username
  databricks_account_password = var.databricks_account_password

  aws_access_key = var.aws_access_key
  aws_secret_key = var.aws_secret_key
  aws_account_id = var.aws_account_id

  metastore_storage_label = var.metastore_storage_label
  metastore_name          = var.metastore_name
  metastore_label         = var.metastore_label
  # metastore_id            = var.metastore_id
}

module "workflows" {
  source                 = "./modules/workflows"
  depends_on             = [ module.aws_ws ]
  providers = {
    databricks = databricks.databricks
  }

  project_name           = "${var.project_name}_${random_pet.this.id}"
  # DE specific
  data_storage_path      = module.aws_ws.metastore_s3_bucket
  de_database_name       = var.de_database_name
  
  # Dev cluster specific
  catalog_name           = "${var.project_name}_${random_pet.this.id}_catalog"

  # Generally applicable
  dev_cluster_id         = module.compute.all_purpose_id
  # git_pat                = var.git_pat
  # git_user               = var.git_user
  git_url                = var.git_url
  git_branch             = var.git_branch 
  git_provider           = var.git_provider

  db_host = module.aws_ws.databricks_host
  db_token = module.aws_ws.databricks_token

}

module "compute" {
  source = "./modules/compute"

  project_name                 = "${var.project_name}_${random_pet.this.id}"

  autotermination_minutes      = var.autotermination_minutes
  tags                         = tomap({"project" = var.project_name}) 

  sql_cluster_size             = var.sql_cluster_size

  db_host  = module.aws_ws.databricks_host
  db_token = module.aws_ws.databricks_token
}

module "queries" {
  source = "./modules/queries"

  project_name                 = "${var.project_name}_${random_pet.this.id}"

  sql_warehouse_data_source_id = module.compute.sql_warehouse_id
  catalog_name                 = "${var.project_name}_${random_pet.this.id}_catalog"
  de_database_name             = var.de_database_name
  
  db_host  = module.aws_ws.databricks_host
  db_token = module.aws_ws.databricks_token
}

output "databricks_host" {
  value = module.aws_ws.databricks_host
}

output "databricks_token" {
  value     = module.aws_ws.databricks_token
  sensitive = true
}

output "random_id" {
  value = random_pet.this.id
}

