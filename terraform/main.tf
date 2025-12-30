terraform {
  required_version = ">= 1.3"
  required_providers {
    esxi = {
      source = "josenk/esxi"
    }
    local = {
      source = "hashicorp/local"
    }
  }
}

provider "esxi" {
  esxi_hostname = var.esxi_hostname
  esxi_username = var.esxi_username
  esxi_password = var.esxi_password
}

resource "esxi_guest" "vm" {
  guest_name = "les03-vm"

  disk_store = var.disk_store
  guestos    = "ubuntu-64"

  memsize  = 2048
  numvcpus = 1
  power    = "on"

  ovf_source = var.ovf_source

  network_interfaces {
    virtual_network = var.virtual_network
  }

  ovf_properties {
    key   = "hostname"
    value = "les03-vm"
  }

  ovf_properties {
    key   = "user-data"
    value = base64encode(templatefile("${path.module}/cloud-init.yaml", {
      username = var.ssh_user
      ssh_key  = var.ssh_public_key
    }))
  }

  ovf_properties {
    key   = "meta-data"
    value = base64encode(<<EOF
instance-id: les03-vm
local-hostname: les03-vm
EOF
    )
  }

  ovf_properties {
    key   = "user-data.encoding"
    value = "base64"
  }
}

resource "local_file" "inventory" {
  filename = "${path.module}/../ansible/inventory.ini"
  content  = templatefile("${path.module}/inventory.tpl", {
    ip = esxi_guest.vm.ip_address
  })
}

