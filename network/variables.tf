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
