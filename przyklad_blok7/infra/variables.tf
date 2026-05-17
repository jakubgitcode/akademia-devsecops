variable "environment" {
  description = "Nazwa środowiska"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Region Azure"
  type        = string
  default     = "Poland Central"
}

variable "project_name" {
  description = "Nazwa projektu"
  type        = string
  default     = "ansible-patch"
}

variable "vm_size" {
  description = "Rozmiar VM"
  type        = string
  default     = "Standard_B2s"
}

variable "linux_vm_count" {
  description = "Liczba VM Linux"
  type        = number
  default     = 2
}

variable "admin_username" {
  description = "Użytkownik admin"
  type        = string
  default     = "azureadmin"
}

variable "tags" {
  description = "Tagi wspólne"
  type        = map(string)
  default     = {}
}
