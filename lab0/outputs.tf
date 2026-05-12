output "project_name" {
  description = "Losowa nazwa projektu z random_pet"
  value       = random_pet.project_name.id
}

output "deployment_id" {
  description = "Przykladowy identyfikator laczacy kilka losowych wartosci"
  value       = "${local.name_prefix}-${random_pet.project_name.id}-${random_string.suffix.result}"
}

output "deployment_config" {
  description = "Przykladowy obiekt konfiguracyjny budowany z variables i random"
  value = {
    environment = var.environment
    owner       = var.owner
    replicas    = random_integer.replica_count.result
    token_len   = var.password_length
  }
}

output "api_token" {
  description = "Wygenerowany token (sensitive output)"
  value       = random_password.api_token.result
  sensitive   = true
}
