resource "azurerm_virtual_network" "network1" {
  name                = var.network_name
  resource_group_name = var.RG_name
  location            = var.lokasjon
  address_space       = var.network_address_space
}

resource "azurerm_subnet" "subnet" {
  #count                = length(var.subnet_name)
  name                 = var.subnet_name[0]
  resource_group_name  = var.RG_name
  virtual_network_name = azurerm_virtual_network.network1.name
  address_prefixes     = [var.subnet_address_space[0]]
}

resource "azurerm_network_interface" "nic" {
  count               = length(var.nic_name) 
  name                = var.nic_name[count.index]
  resource_group_name = var.RG_name
  location            = var.lokasjon

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    #public_ip_address_id	  = azurerm_public_ip.VMIP[count.index].id
  }
}


output "nic_ids" {
#  value = [for i in azurerm_network_interface.nic.map : i.id[*]]
  value = azurerm_network_interface.nic[*].id
}
output "subnet_ids" {
  value = azurerm_subnet.subnet.id
}
