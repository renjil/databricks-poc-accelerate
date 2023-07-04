// Initialize the Databricks provider in "normal" (workspace) mode.
// See https://registry.terraform.io/providers/databricks/databricks/latest/docs#authentication
provider "databricks" {
  // In workspace mode, you don't have to give providers aliases. Doing it here, however,
  // makes it easier to reference, for example when creating a Databricks personal access token
  // later in this file.
  alias = "created_workspace"
  host = databricks_mws_workspaces.this.workspace_url
  token = databricks_mws_workspaces.this.token[0].token_value
}

// Create a Databricks personal access token, to provision entities within the workspace.
# resource "databricks_token" "pat" {
#   provider = databricks.created_workspace
#   comment  = "Terraform Provisioning"
#   lifetime_seconds = 86400
# }

resource "databricks_metastore" "metastore" {
  # count         = var.metastore_id == null ? 1 : 0
  provider      = databricks.created_workspace
  name          = var.metastore_name
  storage_root  = "s3://${aws_s3_bucket.metastore_bucket.id}/${var.metastore_label}"
  force_destroy = true
}

resource "databricks_metastore_data_access" "metastore_data_access" {
  # count         = var.metastore_id == null ? 1 : 0
  provider      = databricks.created_workspace
  depends_on   = [ databricks_metastore.metastore, aws_iam_role.metastore_data_access, databricks_metastore_assignment.default_metastore ]
  metastore_id = databricks_metastore.metastore.id
  name         = aws_iam_role.metastore_data_access.name
  aws_iam_role { role_arn = aws_iam_role.metastore_data_access.arn }
  is_default   = true
}

resource "databricks_metastore_assignment" "default_metastore" {
  provider      = databricks.created_workspace
  depends_on    = [ databricks_mws_workspaces.this ]
  workspace_id  = databricks_mws_workspaces.this.workspace_id
  # metastore_id  = try( var.metastore_id, databricks_metastore.metastore[0].id)
  metastore_id = databricks_metastore.metastore.id
  # default_catalog_name = var.default_metastore_default_catalog_name
}

resource "databricks_storage_credential" "external" {
  provider      = databricks.created_workspace
  depends_on = [ aws_iam_role.metastore_data_access, databricks_metastore_assignment.default_metastore ]
  name = "${local.prefix}-cred"
  aws_iam_role {
    role_arn = aws_iam_role.metastore_data_access.arn
  }
  comment = "POC Accl - Managed by TF"
}

resource "databricks_external_location" "some" {
  provider        = databricks.created_workspace
  depends_on = [ databricks_storage_credential.external ]
  name            = "${local.prefix}-ext"
  url             = "s3://${aws_s3_bucket.metastore_bucket.id}/demo"
  credential_name = databricks_storage_credential.external.id
  comment         = "POC Accl - Managed by TF"
}