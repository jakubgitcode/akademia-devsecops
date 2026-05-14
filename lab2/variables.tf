variable "resource_group_name" {
  description = "Nazwa grupy zasobów."
  type        = string
  default     = "tf-lab2-rg"
}

variable "storage_account_prefix" {
  description = "Prefiks nazwy konta magazynu (tylko małe litery i cyfry, 3-11 znaków)."
  type        = string
  default     = "tflab2sa"
  validation {
    condition     = can(regex("^[a-z0-9]{3,11}$", var.storage_account_prefix))
    error_message = "Prefiks musi zawierać 3-11 znaków: tylko małe litery i cyfry."
  }
}

variable "location" {
  description = "Region Azure, w którym zostaną utworzone zasoby."
  type        = string
  default     = "West Europe"
}
