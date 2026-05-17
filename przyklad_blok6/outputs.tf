output "resource_group_name" {
  description = "Nazwa resource group"
  value       = azurerm_resource_group.main.name
}

output "vm_ids" {
  description = "Mapa ID maszyn wirtualnych"
  value       = { for k, v in azurerm_linux_virtual_machine.main : k => v.id }
}

output "vm_private_ips" {
  description = "Mapa prywatnych IP maszyn wirtualnych"
  value       = { for k, v in azurerm_linux_virtual_machine.main : k => v.private_ip_address }
}

output "maintenance_configuration_id" {
  description = "ID konfiguracji maintenance"
  value       = azurerm_maintenance_configuration.patch_window.id
}

output "patch_schedule_summary" {
  description = "Podsumowanie harmonogramu patchowania"
  value = {
    environment = var.environment
    recurrence  = var.patch_window_recurrence
    duration    = var.patch_window_duration
    reboot      = var.patch_reboot_policy
    vm_count    = var.vm_count
  }
}
