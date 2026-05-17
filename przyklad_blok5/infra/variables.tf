variable "environment" {
  description = "Nazwa środowiska (dev, test, prod)"
  type        = string
}

variable "location" {
  description = "Region Azure"
  type        = string
  default     = "Poland Central"
}

variable "project_name" {
  description = "Nazwa projektu — używana w nazwach zasobów"
  type        = string
  default     = "blok5"
}

variable "vnet_address_space" {
  description = "Przestrzeń adresowa VNET"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "Mapa podsieci do utworzenia"
  type = map(object({
    address_prefixes = list(string)
  }))
  default = {}
}

variable "tags" {
  description = "Tagi wspólne dla wszystkich zasobów"
  type        = map(string)
  default     = {}
}
