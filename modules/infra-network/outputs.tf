output "private_dns_zone_id" {
  value = azurerm_private_dns_zone.pe_private_dns.id
}

output "private_dns_zone_name" {
  value = azurerm_private_dns_zone.pe_private_dns.name
}
