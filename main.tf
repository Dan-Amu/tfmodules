# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.6.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = "3d603316-5971-439d-8021-18c7503b2964"
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = var.RG_name
  location = var.lokasjon
}

module "network" {
  source = "./network"
}
/*
module "VM" {
  source = "./VM"
}
*/
resource "azurerm_ssh_public_key" "id_azure1" {
  name                = var.sshkey_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  public_key          = file(var.sshkey_path)
}
/*
# Create a virtual network within the resource group
resource "azurerm_network_interface" "nic" {
  count               = length(var.nic_name) 
  name                = var.nic_name[count.index]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.network.azurerm_subnet.id
    private_ip_address_allocation = "Dynamic"
    #public_ip_address_id	  = azurerm_public_ip.VMIP[count.index].id
  }
}

resource "azurerm_public_ip" "VMIP" {
  count               = length(var.vm_public_ips)
  name                = var.vm_public_ips[count.index]
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  allocation_method   = "Static"
  ip_tags             = {}
  sku                 = "Standard"
  tags = {
    environment = "Production"
  }
} 

resource "azurerm_public_ip" "LB1IP" {
  name                = var.lb_public_ips
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    environment = "Production"
  }
}

*/
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



# Associate Network Interface to the Backend Pool of the Load Balancer
resource "azurerm_network_interface_backend_address_pool_association" "my_nic_lb_pool1" {
  count = length(var.vm_names)
  network_interface_id    = module.network.nic_ids[count.index]
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.my_lb_pool.id
}
# Create Public Load Balancer
resource "azurerm_lb" "my_lb" {
  name                = var.lb_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = module.network.LB1IP_name
    public_ip_address_id = module.network.LB1IP_id
  }
}

resource "azurerm_lb_backend_address_pool" "my_lb_pool" {
  loadbalancer_id      = azurerm_lb.my_lb.id
  name                 = "test-pool"
}

resource "azurerm_lb_probe" "my_lb_probe" {
  loadbalancer_id     = azurerm_lb.my_lb.id
  name                = "test-probe"
  port                = 80
}

resource "azurerm_lb_rule" "my_lb_rule" {
  loadbalancer_id                = azurerm_lb.my_lb.id
  name                           = "test-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  disable_outbound_snat          = true
  frontend_ip_configuration_name = module.network.LB1IP_name
  probe_id                       = azurerm_lb_probe.my_lb_probe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.my_lb_pool.id]
}

resource "azurerm_lb_outbound_rule" "my_lboutbound_rule" {
  name                    = "test-outbound"
  loadbalancer_id         = azurerm_lb.my_lb.id
  protocol                = "Tcp"
  backend_address_pool_id = azurerm_lb_backend_address_pool.my_lb_pool.id

  frontend_ip_configuration {
    name = module.network.LB1IP_name
  }
}

output "LB_IP_address" {
  value = module.network.LB_IP_address
}
