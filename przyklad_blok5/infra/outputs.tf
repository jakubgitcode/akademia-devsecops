output "resource_group_name" {
  description = "Nazwa resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID resource group"
  value       = azurerm_resource_group.main.id
}

output "vnet_id" {
  description = "ID sieci wirtualnej"
  value       = azurerm_virtual_network.main.id
}

output "subnet_ids" {
  description = "Mapa ID podsieci"
  value       = { for k, v in azurerm_subnet.main : k => v.id }
}
