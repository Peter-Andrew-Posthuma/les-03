terraform {
  required_version = ">= 1.3"
  required_providers {
    esxi = {
      source = "josenk/esxi"
    }
  }
}

provider "esxi" {
  esxi_hostname = var.esxi_hostname
  esxi_username = var.esxi_username
  esxi_password = var.esxi_password
}

# ------------------------
# Webservers (2x)
# ------------------------
resource "esxi_guest" "webserver" {
  count      = var.webserver_count
  guest_name = "webserver${count.index + 1}"

  disk_store = var.disk_store
  guestos    = "ubuntu-64"

  memsize  = 2048
  numvcpus = 1
  power    = "on"

  ovf_source = var.ovf_source

  network_interfaces {
    virtual_network = var.virtual_network
  }

  # Hostname in ESXi
  ovf_properties {
    key   = "hostname"
    value = "webserver${count.index + 1}"
  }

  # -------- cloud-init: user-data --------
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

  # -------- cloud-init: meta-data --------
  ovf_properties {
    key = "meta-data"
    value = base64encode(<<EOF
instance-id: webserver${count.index + 1}
local-hostname: webserver${count.index + 1}
EOF
    )
  }

  ovf_properties {
    key   = "meta-data.encoding"
    value = "base64"
  }
}

# ------------------------
# Database server (1x)
# ------------------------
resource "esxi_guest" "dbserver" {
  guest_name = var.dbserver_name

  disk_store = var.disk_store
  guestos    = "ubuntu-64"

  memsize  = 2048
  numvcpus = 1
  power    = "on"

  ovf_source = var.ovf_source

  network_interfaces {
    virtual_network = var.virtual_network
  }

  # Hostname in ESXi
  ovf_properties {
    key   = "hostname"
    value = var.dbserver_name
  }

  # -------- cloud-init: user-data --------
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

  # -------- cloud-init: meta-data --------
  ovf_properties {
    key = "meta-data"
    value = base64encode(<<EOF
instance-id: ${var.dbserver_name}
local-hostname: ${var.dbserver_name}
EOF
    )
  }

  ovf_properties {
    key   = "meta-data.encoding"
    value = "base64"
  }
}