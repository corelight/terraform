output "fleet_public_ip" {
  description = "The public IP address of the Fleet load balancer"
  value       = azurerm_public_ip.fleet.ip_address
}

output "fleet_fqdn" {
  description = "The fully qualified domain name for Fleet (if DNS is configured)"
  value       = var.dns_zone_name != null ? "${var.subdomain}.${var.dns_zone_name}" : null
}

output "fleet_vm_id" {
  description = "Resource ID of the Fleet VM"
  value       = azurerm_linux_virtual_machine.fleet.id
}

output "fleet_private_ip" {
  description = "Private IP address of the Fleet VM"
  value       = azurerm_network_interface.fleet.private_ip_address
}

output "nsg_id" {
  description = "The NSG ID in use (created or provided)"
  value       = local.nsg_id
}

output "lb_id" {
  description = "Resource ID of the Fleet load balancer"
  value       = azurerm_lb.fleet.id
}
