#variables.tf

variable "name" {
  description    = "blabla"
  type           = string
  default        = "bla"
}

variable "lokasjon" {
  description    = "Lokasjon"
  type           = string
  default        = "Norway East"
}

variable "RG_name" {
  description    = "Navn på ressursgruppe"
  type           = string
  default        = "LB-test"
}

variable "sshkey_name" {
  description    = "Navn på ssh-nøkkel"
  type           = string
  default        = "id_azure1"
}

variable "sshkey_path" {
  description    = "Fil-plassering til ssh-nøkkel"
  type           = string
  default        = "C:/Users/dan/.ssh/id_azure1.pub"
}
/*
variable "network_name" {
  description    = "Name of network"
  type           = string
  default        = "network-1"
}

variable "network_address_space" {
  description    = "Address space of network"
  type           = list
  default        = ["192.168.0.0/16"]
}

variable "subnet_name" {
  description    = "Name of subnets"
  type           = list
  default        = ["subnet1"]
}

variable "subnet_address_space" {
  description    = "Address space of subnets"
  type           = list
  default        = ["192.168.1.0/24", "192.168.2.0/24"]
}

variable "nic_name" {
  description    = "Name of nics"
  type           = list
  default        = ["nic1", "nic2"]
}

variable "vm_public_ips" {
  description    = "Names of public ips for vms"
  type           = list
  default        = ["VM1IP", "VM2IP"]
}

variable "lb_public_ips" {
  description    = "Name of public ip for lb"
  type           = string
  default        = "LB1IP"
}
*/
variable "vm_names" {
  description    = "Name of vms"
  type           = list
  default        = ["VM-1", "VM-2"]
}

variable "vm_type" {
  description    = "type of vms"
  type           = string
  default        = "Standard_B1s"
}

variable "admin_user" {
  description    = "admin username"
  type           = string
  default        = "dan"
}

variable "lb_name" {
  description    = "Name of load balancer"
  type           = string
  default        = "BalanceMyLoad"
}
