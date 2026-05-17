resource "azurerm_virtual_network" "main" {
  name                = "vnet-${local.resource_name_prefix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = var.vnet_address_space
  tags                = local.common_tags
}

resource "azurerm_subnet" "main" {
  name                 = "snet-${local.resource_name_prefix}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.subnet_address_prefixes
}

resource "azurerm_network_security_group" "main" {
  name                = "nsg-${local.resource_name_prefix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = local.common_tags

  # Domyślnie: brak reguł = deny all inbound (bezpieczne)
}
