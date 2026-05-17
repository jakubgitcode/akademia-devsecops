# --- Klucz SSH (generowany automatycznie) ---
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# --- NIC per VM ---
resource "azurerm_network_interface" "main" {
  for_each = local.vm_names

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

# --- Linux VM z konfiguracją pod Azure Update Manager ---
resource "azurerm_linux_virtual_machine" "main" {
  for_each = local.vm_names

  name                = "${local.resource_name_prefix}-${each.key}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = var.vm_size

  admin_username = var.admin_username

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.ssh.public_key_openssh
  }

  network_interface_ids = [azurerm_network_interface.main[each.key].id]

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

  # ========================================
  # KLUCZOWE dla Azure Update Manager:
  # ========================================
  # patch_mode musi być "AutomaticByPlatform" aby AUM zarządzał patchami
  patch_mode = "AutomaticByPlatform"

  # patch_assessment_mode musi być "AutomaticByPlatform" dla periodic assessment
  patch_assessment_mode = "AutomaticByPlatform"

  # bypass_platform_safety_checks_on_user_schedule — wymagane dla
  # in_guest_user_patch_mode = "User" w maintenance_configuration
  bypass_platform_safety_checks_on_user_schedule_enabled = true

  tags = merge(local.common_tags, {
    patch_group = "${var.environment}-scheduled"
    patch_ring  = each.value == 0 ? "canary" : "broad"
  })
}
