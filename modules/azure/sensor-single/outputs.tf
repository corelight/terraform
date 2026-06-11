output "sensor_vm_id" {
  description = "Resource ID of the sensor VM"
  value       = azurerm_linux_virtual_machine.sensor.id
}

output "sensor_private_ip_address" {
  description = "Private IP address of the management NIC"
  value       = azurerm_network_interface.management.private_ip_address
}

output "sensor_public_ip_address" {
  description = "Public IP address of the management NIC (if enabled)"
  value       = var.management_interface_public_ip ? azurerm_public_ip.management[0].ip_address : null
}

output "management_interface_id" {
  description = "Network interface ID for management traffic"
  value       = azurerm_network_interface.management.id
}

output "monitoring_interface_id" {
  description = "Network interface ID for monitoring traffic"
  value       = azurerm_network_interface.monitoring.id
}
