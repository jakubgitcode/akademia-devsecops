# ==================================================
# Azure Update Manager — Maintenance Configuration
# ==================================================

resource "azurerm_maintenance_configuration" "patch_window" {
  name                     = "mc-patch-${var.environment}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  scope                    = "InGuestPatch"
  in_guest_user_patch_mode = "User"

  tags = local.common_tags

  install_patches {
    reboot = var.patch_reboot_policy

    linux {
      classifications_to_include = var.patch_linux_classifications
    }

    windows {
      classifications_to_include = var.patch_windows_classifications
    }
  }

  window {
    start_date_time = var.patch_window_start
    duration        = var.patch_window_duration
    time_zone       = var.patch_window_time_zone
    recur_every     = var.patch_window_recurrence
  }
}

# ==================================================
# Static Assignment — VM per VM (for_each)
# ==================================================

resource "azurerm_maintenance_assignment_virtual_machine" "main" {
  for_each = azurerm_linux_virtual_machine.main

  location                     = azurerm_resource_group.main.location
  maintenance_configuration_id = azurerm_maintenance_configuration.patch_window.id
  virtual_machine_id           = each.value.id
}

# ==================================================
# Dynamic Scope — Tag-based (opcjonalne)
# ==================================================
# Automatycznie przypisuje KAŻDĄ VM z odpowiednimi tagami
# do maintenance configuration. Nowe VM z tagami będą
# automatycznie objęte harmonogramem.

resource "azurerm_maintenance_assignment_dynamic_scope" "auto" {
  count = var.enable_dynamic_scope ? 1 : 0

  name                         = "ds-patch-${var.environment}"
  maintenance_configuration_id = azurerm_maintenance_configuration.patch_window.id

  filter {
    resource_types = ["Microsoft.Compute/virtualMachines"]
    locations      = [var.location]
    os_types       = ["Linux"]
    tag_filter     = "All"

    tags {
      tag    = "patch_group"
      values = ["${var.environment}-scheduled"]
    }

    tags {
      tag    = "Environment"
      values = [var.environment]
    }
  }
}
