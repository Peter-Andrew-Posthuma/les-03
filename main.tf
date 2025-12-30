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

# ------------------------
# Webservers (web-1, web-2)
# ------------------------
resource "esxi_guest" "web" {
  count      = 2
  guest_name = "web-${count.index + 1}"

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
    value = "web-${count.index + 1}"
  }

  ovf_properties {
    key = "user-data"
    value = base64encode(
      templatefile("${path.module}/cloud-init.yaml", {
        cloudinit_user = var.cloudinit_user
        ssh_public_key = var.ssh_public_key
      })
    )
  }

  ovf_properties {
    key   = "user-data.encoding"
    value = "base64"
  }

  ovf_properties {
    key = "meta-data"
    value = base64encode(<<EOF
instance-id: web-${count.index + 1}
local-hostname: web-${count.index + 1}
EOF
    )
  }

  ovf_properties {
    key   = "meta-data.encoding"
    value = "base64"
  }
}

# ------------------------
# Database server (db-1)
# ------------------------
resource "esxi_guest" "db" {
  guest_name = "db-1"

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
    value = "db-1"
  }

  ovf_properties {
    key = "user-data"
    value = base64encode(
      templatefile("${path.module}/cloud-init.yaml", {
        cloudinit_user = var.cloudinit_user
        ssh_public_key = var.ssh_public_key
      })
    )
  }

  ovf_properties {
    key   = "user-data.encoding"
    value = "base64"
  }

  ovf_properties {
    key = "meta-data"
    value = base64encode(<<EOF
instance-id: db-1
local-hostname: db-1
EOF
    )
  }

  ovf_properties {
    key   = "meta-data.encoding"
    value = "base64"
  }
}

# ------------------------
# AUTOMATISCHE INVENTORY
# ------------------------
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/ansible/inventory.ini"

  content = templatefile("${path.module}/inventory.tpl", {
    web_ips = esxi_guest.web[*].ip_address
    db_ip  = esxi_guest.db.ip_address
  })
}

