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

output "vm_public_ips" {
  description = "Mapa publicznych IP VM Linux"
  value       = { for k, v in azurerm_public_ip.linux : k => v.ip_address }
  sensitive   = true
}

output "ssh_private_key" {
  description = "Prywatny klucz SSH do połączenia z VM (PEM)"
  value       = tls_private_key.ssh.private_key_openssh
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
              ansible_host = azurerm_public_ip.linux[k].ip_address
              ansible_user = var.admin_username
              patch_ring   = v.tags["patch_ring"]
            }
          }
        }
      }
    }
  })
}
