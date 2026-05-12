variable "environment" {
  description = "Nazwa srodowiska (np. dev, test, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Dozwolone wartosci: dev, test, prod."
  }
}

variable "owner" {
  description = "Wlasciciel konfiguracji - trafi do local.name_prefix"
  type        = string
  default     = "devops-team"
}

variable "name_prefix" {
  description = "Opcjonalny prefix dla random_pet"
  type        = string
  default     = "lab0"
}

variable "pet_words" {
  description = "Liczba slow generowanych przez random_pet"
  type        = number
  default     = 2

  validation {
    condition     = var.pet_words >= 1 && var.pet_words <= 3
    error_message = "pet_words musi byc w zakresie 1-3."
  }
}

variable "separator" {
  description = "Separator miedzy slowami random_pet"
  type        = string
  default     = "-"
}

variable "suffix_length" {
  description = "Dlugosc alfanumerycznego sufiksu"
  type        = number
  default     = 6

  validation {
    condition     = var.suffix_length >= 4 && var.suffix_length <= 12
    error_message = "suffix_length musi byc w zakresie 4-12."
  }
}

variable "replicas_min" {
  description = "Dolny zakres dla random_integer"
  type        = number
  default     = 2
}

variable "replicas_max" {
  description = "Gorny zakres dla random_integer"
  type        = number
  default     = 5

  validation {
    condition     = var.replicas_max >= 2
    error_message = "replicas_max musi byc >= 2."
  }
}

variable "password_length" {
  description = "Dlugosc tokenu generowanego przez random_password"
  type        = number
  default     = 20

  validation {
    condition     = var.password_length >= 12
    error_message = "password_length musi byc >= 12."
  }
}

variable "password_special" {
  description = "Czy token ma zawierac znaki specjalne"
  type        = bool
  default     = false
}
