# ==================================================
# Azure Policy — Wymuszenie patchowania
# ==================================================

# Built-in policy (current):
# "System updates should be installed on your machines (powered by Update Center)"
data "azurerm_policy_definition" "updates_installed" {
  # Use the built-in policy definition GUID to avoid breakage when display names change.
  name = "f85bf3e0-d513-442e-89c3-1784ad63382b"
}

resource "azurerm_resource_group_policy_assignment" "require_updates" {
  name                 = "require-system-updates-${var.environment}"
  resource_group_id    = azurerm_resource_group.main.id
  policy_definition_id = data.azurerm_policy_definition.updates_installed.id
  display_name         = "Require system updates on VMs (${var.environment})"

  # DoNotEnforce w środowisku szkoleniowym — audyt bez blokowania
  enforce = false
}
