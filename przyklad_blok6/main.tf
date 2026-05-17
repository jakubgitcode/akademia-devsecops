resource "azurerm_resource_group" "main" {
  name     = "rg-${local.resource_name_prefix}"
  location = var.location
  tags     = local.common_tags
}
