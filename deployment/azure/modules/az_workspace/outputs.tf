output "databricks_host" {
  value = azurerm_databricks_workspace.this.workspace_url
}

/*
output "databricks_token" {
  value     = azurerm_databricks_workspace.this.token[0].token_value
  sensitive = true
}
*/

output "databricks_workspace_id" {
  value     = azurerm_databricks_workspace.this.workspace_id
}

output "adls_storage_account" {
  value = azurerm_storage_account.unity_catalog.name
}

output "adls_storage_container" {
  value = azurerm_storage_container.unity_catalog.name
}