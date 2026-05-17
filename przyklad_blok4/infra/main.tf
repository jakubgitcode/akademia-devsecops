# =====================================================
# Resource Group
# =====================================================
resource "azurerm_resource_group" "main" {
  name     = "rg-${local.resource_name_prefix}"
  location = var.location
  tags     = local.common_tags
}

# =====================================================
# Virtual Network + Subnets
# =====================================================
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${local.resource_name_prefix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = var.vnet_address_space
  tags                = local.common_tags
}

resource "azurerm_subnet" "main" {
  for_each = var.subnets

  name                 = "snet-${each.key}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = each.value.address_prefixes
  service_endpoints    = each.value.service_endpoints
}

# =====================================================
# Network Security Group
# =====================================================
resource "azurerm_network_security_group" "main" {
  name                = "nsg-${local.resource_name_prefix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = local.common_tags
}

# =====================================================
# Storage Account (secure by default)
# =====================================================
resource "azurerm_storage_account" "main" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_replication_type

  # Security hardening
  https_traffic_only_enabled = var.enable_https_only
  min_tls_version            = "TLS1_2"

  # Blokada public blob access
  allow_nested_items_to_be_public = false

  tags = local.common_tags
}
