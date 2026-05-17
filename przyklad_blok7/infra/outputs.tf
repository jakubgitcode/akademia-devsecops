# --- Inventory YAML dla Ansible (generowany z Terraform output) ---

output "resource_group_name" {
  description = "Nazwa resource group"
  value       = azurerm_resource_group.main.name
}

output "vm_private_ips" {
  description = "Mapa prywatnych IP VM Linux"
  value       = { for k, v in azurerm_linux_virtual_machine.main : k => v.private_ip_address }
  sensitive   = true
}

output "ansible_inventory" {
  description = "Inventory YAML dla Ansible — zapis do pliku hosts.yml"
  sensitive   = true
  value = yamlencode({
    all = {
      children = {
        linux = {
          hosts = {
            for k, v in azurerm_linux_virtual_machine.main : k => {
              ansible_host = v.private_ip_address
              ansible_user = var.admin_username
              patch_ring   = v.tags["patch_ring"]
            }
          }
        }
      }
    }
  })
}
