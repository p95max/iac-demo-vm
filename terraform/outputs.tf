output "public_ip" {
  value = azurerm_public_ip.vm.ip_address
}

output "ansible_inventory" {
  value = templatefile("${path.module}/../ansible/inventory.ini.j2", {
    public_ip      = azurerm_public_ip.vm.ip_address
    admin_username = var.admin_username
  })
}