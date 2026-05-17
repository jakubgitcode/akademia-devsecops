variable "environment" {
  description = "Nazwa środowiska (dev, test, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Środowisko musi być: dev, test lub prod."
  }
}

variable "location" {
  description = "Region Azure"
  type        = string
  default     = "Poland Central"
}

variable "project_name" {
  description = "Nazwa projektu — używana w prefixach zasobów"
  type        = string
  default     = "blok4"
}

variable "vnet_address_space" {
  description = "Przestrzeń adresowa VNET"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "Mapa podsieci do utworzenia"
  type = map(object({
    address_prefixes  = list(string)
    service_endpoints = optional(list(string), [])
  }))
  default = {}
}

variable "storage_account_tier" {
  description = "Tier konta storage (Standard, Premium)"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "Tier musi być Standard lub Premium."
  }
}

variable "storage_replication_type" {
  description = "Typ replikacji storage (LRS, GRS, ZRS)"
  type        = string
  default     = "LRS"
}

variable "enable_https_only" {
  description = "Wymuszenie HTTPS na storage account"
  type        = bool
  default     = true
}

variable "min_tls_version" {
  description = "Minimalna wersja TLS"
  type        = string
  default     = "TLS1_2"
}

variable "tags" {
  description = "Tagi wspólne"
  type        = map(string)
  default     = {}
}
