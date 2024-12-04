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
  name     = "LB-test"
  location = "Norway East"
}

resource "azurerm_ssh_public_key" "id_azure1" {
  name                = "id_azure1"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  public_key          = file("C:/Users/dan/.ssh/id_azure1.pub")
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "network1" {
  name                = "network-1"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["192.168.0.0/16"]
}

resource "azurerm_subnet" "subnet1" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.network1.name
  address_prefixes     = ["192.168.1.0/24"]
}

resource "azurerm_network_interface" "nic1" {
  name                = "nic-1"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id	        = azurerm_public_ip.VM1IP.id
  }
}

resource "azurerm_network_interface" "nic2" {
  name                = "nic-2"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id      	  = azurerm_public_ip.VM2IP.id
  }
}
resource "azurerm_public_ip" "VM2IP" {
  name                = "VM2IP"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  allocation_method   = "Static"
  ip_tags             = {}
  sku                 = "Standard"
  tags = {
    environment = "Production"
  }
} 
resource "azurerm_public_ip" "VM1IP" {
  name                = "VM1IP"
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
  name                = "LB1IP"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    environment = "Production"
  }
}

resource "azurerm_linux_virtual_machine" "VM1" {
  name                = "VM-1"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_B1s"
  admin_username      = "dan"
  network_interface_ids = [
    azurerm_network_interface.nic1.id,
  ]

  admin_ssh_key {
    username   = "dan"
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

resource "azurerm_linux_virtual_machine" "VM2" {
  name                = "VM-2"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_B1s"
  admin_username      = "dan"
  network_interface_ids = [
    azurerm_network_interface.nic2.id,
  ]

  admin_ssh_key {
    username   = "dan"
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
  network_interface_id    = azurerm_network_interface.nic1.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.my_lb_pool.id
}
resource "azurerm_network_interface_backend_address_pool_association" "my_nic_lb_pool2" {
  network_interface_id    = azurerm_network_interface.nic2.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.my_lb_pool.id
}
# Create Public Load Balancer
resource "azurerm_lb" "my_lb" {
  name                = "BalanceMyLoad"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "LB1IP"
    public_ip_address_id = azurerm_public_ip.LB1IP.id
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
  frontend_ip_configuration_name = "LB1IP"
  probe_id                       = azurerm_lb_probe.my_lb_probe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.my_lb_pool.id]
}

resource "azurerm_lb_outbound_rule" "my_lboutbound_rule" {
  name                    = "test-outbound"
  loadbalancer_id         = azurerm_lb.my_lb.id
  protocol                = "Tcp"
  backend_address_pool_id = azurerm_lb_backend_address_pool.my_lb_pool.id

  frontend_ip_configuration {
    name = "LB1IP"
  }
}
