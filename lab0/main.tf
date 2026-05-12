terraform {
  required_version = ">= 1.5.0"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0"
    }
  }
}

# Local backend only (default). Intentionally no backend block defined.

locals {
  normalized_owner = lower(replace(var.owner, " ", "-"))
  name_prefix      = "${var.environment}-${local.normalized_owner}"
}

resource "random_pet" "project_name" {
  length    = var.pet_words
  separator = var.separator
  prefix    = var.name_prefix
}

resource "random_string" "suffix" {
  length  = var.suffix_length
  upper   = false
  lower   = true
  numeric = true
  special = false
}

resource "random_integer" "replica_count" {
  min = var.replicas_min
  max = var.replicas_max
}

resource "random_password" "api_token" {
  length  = var.password_length
  special = var.password_special
}
