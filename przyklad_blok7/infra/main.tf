locals {
  resource_name_prefix = "${var.project_name}-${var.environment}"

  common_tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  })

  linux_vm_names = { for i in range(var.linux_vm_count) : "linux-${i + 1}" => i }
}

# --- Resource Group ---
resource "azurerm_resource_group" "main" {
  name     = "rg-${local.resource_name_prefix}"
  location = var.location
  tags     = local.common_tags
}

# --- Networking ---
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${local.resource_name_prefix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["10.30.0.0/16"]
  tags                = local.common_tags
}

resource "azurerm_subnet" "main" {
  name                 = "snet-${local.resource_name_prefix}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.30.1.0/24"]
}

# --- SSH Key ---
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# --- NIC ---
resource "azurerm_network_interface" "linux" {
  for_each = local.linux_vm_names

  name                = "nic-${local.resource_name_prefix}-${each.key}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = local.common_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }
}

# --- Linux VM ---
resource "azurerm_linux_virtual_machine" "main" {
  for_each = local.linux_vm_names

  name                = "${local.resource_name_prefix}-${each.key}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = var.vm_size

  admin_username = var.admin_username
  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.ssh.public_key_openssh
  }

  network_interface_ids = [azurerm_network_interface.linux[each.key].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  patch_mode                                             = "AutomaticByPlatform"
  patch_assessment_mode                                  = "AutomaticByPlatform"
  bypass_platform_safety_checks_on_user_schedule_enabled = true

  tags = merge(local.common_tags, {
    ansible_group = "app_servers"
    patch_ring    = each.value == 0 ? "canary" : "broad"
  })
}
