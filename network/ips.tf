
resource "azurerm_public_ip" "VMIP" {
  count               = length(var.vm_public_ips)
  name                = var.vm_public_ips[count.index]
  resource_group_name = var.RG_name
  location            = var.lokasjon
  allocation_method   = "Static"
  ip_tags             = {}
  sku                 = "Standard"
  tags = {
    environment = "Production"
  }
} 

resource "azurerm_public_ip" "LB1IP" {
  name                = var.lb_public_ips
  resource_group_name = var.RG_name
  location            = var.lokasjon
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    environment = "Production"
  }
}

output "LB1IP_id" {
  value = azurerm_public_ip.LB1IP.id
}

output "VMIP_id" {
  value = azurerm_public_ip.VMIP[*].id
}

output "LB1IP_name" {
  value = azurerm_public_ip.LB1IP.name
}

output "VMIP_name" {
  value = azurerm_public_ip.VMIP[*].name
}

output "LB_IP_address" {
  value = azurerm_public_ip.LB1IP.ip_address
}

output "VM_IP_address" {
  value = azurerm_public_ip.VMIP[*].ip_address
}
