resource "azurerm_linux_virtual_machine" "VM" {
  count               = length(var.vm_names) 
  name                = var.vm_names[count.index]
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = var.vm_type
  admin_username      = var.admin_user
  network_interface_ids = [
    module.network.subnet_ids,
  ]

  admin_ssh_key {
    username   = var.admin_user
    public_key = azurerm_ssh_public_key.id_azure1.public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
 
  source_image_reference {
    publisher = "debian"
    offer     = "debian-12-daily"
    sku       = "12-gen2"
    version   = "latest"
  }
}
