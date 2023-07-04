resource "azurerm_resource_group" "this" {
  name     = "${local.prefix}-rg"
  location = "Australia East"
  tags = local.tags
}