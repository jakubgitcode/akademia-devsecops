terraform {
  # Remote backend: Azure Storage Account
  # Backend cannot use variables. Pass values during init or via backend.hcl
  # Example: terraform init \
  #   -backend-config="storage_account_name=<name>" \
  #   -backend-config="container_name=<container>" \
  #   -backend-config="key=lab2.terraform.tfstate"
  backend "azurerm" {
    storage_account_name = "tflab1sa30vv44"
    container_name       = "mojstan"
    key                  = "lab2.terraform.tfstate"
    resource_group_name  = "tf-lab1-rg30vv44"
    use_azuread_auth     = true
  }
}
