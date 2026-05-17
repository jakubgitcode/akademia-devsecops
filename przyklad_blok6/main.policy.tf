# ==================================================
# Azure Policy — Wymuszenie patchowania
# ==================================================

# Built-in policy: "System updates should be installed on your machines"
data "azurerm_policy_definition" "updates_installed" {
  display_name = "System updates should be installed on your machines"
}

resource "azurerm_resource_group_policy_assignment" "require_updates" {
  name                 = "require-system-updates-${var.environment}"
  resource_group_id    = azurerm_resource_group.main.id
  policy_definition_id = data.azurerm_policy_definition.updates_installed.id
  display_name         = "Require system updates on VMs (${var.environment})"

  # DoNotEnforce w środowisku szkoleniowym — audyt bez blokowania
  enforce = false
}
