# ==================================================
# TFLint Configuration — Azure ruleset
# ==================================================
# Docs: https://github.com/terraform-linters/tflint-ruleset-azurerm

plugin "azurerm" {
  enabled = true
  version = "0.27.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

# --- Reguły ogólne Terraform ---

rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_standard_module_structure" {
  enabled = true
}
