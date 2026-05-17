variable "environment" {
  description = "Nazwa środowiska (dev, prod)"
  type        = string
}

variable "location" {
  description = "Region Azure"
  type        = string
  default     = "Poland Central"
}

variable "project_name" {
  description = "Nazwa projektu"
  type        = string
  default     = "patch-mgmt"
}

variable "vm_size" {
  description = "Rozmiar VM"
  type        = string
  default     = "Standard_B2s"
}

variable "vm_count" {
  description = "Liczba VM Linux do utworzenia"
  type        = number
  default     = 1
}

variable "admin_username" {
  description = "Nazwa użytkownika administratora VM"
  type        = string
  default     = "azureadmin"
}

variable "vnet_address_space" {
  description = "Przestrzeń adresowa VNET"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefixes" {
  description = "Prefixy adresowe podsieci"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

# --- Patch Management ---

variable "patch_window_start" {
  description = "Data i godzina rozpoczęcia okna patchowania (YYYY-MM-DD hh:mm)"
  type        = string
  default     = "2024-01-06 02:00"
}

variable "patch_window_duration" {
  description = "Czas trwania okna patchowania (HH:mm)"
  type        = string
  default     = "03:55"
}

variable "patch_window_time_zone" {
  description = "Strefa czasowa okna patchowania"
  type        = string
  default     = "Central European Standard Time"
}

variable "patch_window_recurrence" {
  description = "Częstotliwość patchowania (np. '1Week Saturday', 'Month Second Sunday')"
  type        = string
  default     = "1Week Saturday"
}

variable "patch_reboot_policy" {
  description = "Polityka restartu po patchach: Always, IfRequired, Never"
  type        = string
  default     = "IfRequired"

  validation {
    condition     = contains(["Always", "IfRequired", "Never"], var.patch_reboot_policy)
    error_message = "patch_reboot_policy musi być: Always, IfRequired lub Never."
  }
}

variable "patch_linux_classifications" {
  description = "Klasyfikacje patchy Linux do zainstalowania"
  type        = list(string)
  default     = ["Critical", "Security"]
}

variable "patch_windows_classifications" {
  description = "Klasyfikacje patchy Windows do zainstalowania"
  type        = list(string)
  default     = ["Critical", "Security", "UpdateRollup"]
}

variable "enable_dynamic_scope" {
  description = "Włącz dynamiczne przypisanie VM do maintenance config (tag-based)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tagi wspólne"
  type        = map(string)
  default     = {}
}
