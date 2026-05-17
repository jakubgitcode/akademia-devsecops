terraform {
  required_version = ">= 1.8.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  #backend "azurerm" {
  #  resource_group_name  = "rg-terraform-state"
  #  storage_account_name = "stterraformstate"
  #  container_name       = "tfstate"
  #  use_oidc             = true
  #}
  backend "azurerm" {
    storage_account_name = "tflab1sa30vv44"
    container_name       = "mojstan"
    key                  = "lab5-repo-dso.terraform.tfstate"
    resource_group_name  = "tf-lab1-rg30vv44"
    use_azuread_auth     = true
  }
}

provider "azurerm" {
  features {}
  use_oidc = true
}
