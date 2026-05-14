output "resource_group_name" {
  description = "Nazwa utworzonej grupy zasobów."
  value       = azurerm_resource_group.rg.name
}

output "storage_account_name" {
  description = "Nazwa utworzonego konta magazynu."
  value       = azurerm_storage_account.sa[0].name
}
