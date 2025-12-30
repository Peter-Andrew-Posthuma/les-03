variable "esxi_hostname" {
  type = string
}

variable "esxi_username" {
  type = string
}

variable "esxi_password" {
  type = string
  sensitive = true
}

variable "disk_store" {
  type = string
}

variable "virtual_network" {
  type = string
}

variable "ovf_source" {
  type = string
}

variable "cloudinit_user" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

