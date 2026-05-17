terraform {
  required_version = ">= 1.8.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    storage_account_name = "tflab1sa30vv44"
    container_name       = "mojstan"
    key                  = "lab6-repo-dso.terraform.tfstate"
    resource_group_name  = "tf-lab1-rg30vv44"
    use_azuread_auth     = true
  }
}

provider "azurerm" {
  features {}
  use_oidc = true
}
