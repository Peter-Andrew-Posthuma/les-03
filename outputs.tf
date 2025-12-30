output "web_ips" {
  value = esxi_guest.web[*].ip_address
}

output "db_ip" {
  value = esxi_guest.db.ip_address
}

