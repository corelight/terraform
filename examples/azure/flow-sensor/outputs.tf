output "sensor_vm_id" {
  description = "Resource ID of the flow sensor VM"
  value       = module.sensor.sensor_vm_id
}

output "sensor_private_ip_address" {
  description = "Private IP address of the sensor management NIC"
  value       = module.sensor.sensor_private_ip_address
}

output "sensor_public_ip_address" {
  description = "Public IP address of the sensor management NIC (if enabled)"
  value       = module.sensor.sensor_public_ip_address
}

output "management_interface_id" {
  description = "Network interface ID for management traffic"
  value       = module.sensor.management_interface_id
}

output "monitoring_interface_id" {
  description = "Network interface ID for monitoring traffic"
  value       = module.sensor.monitoring_interface_id
}

output "vnet_flow_identity_id" {
  description = "Resource ID of the managed identity for VNet flow log access"
  value       = module.vnet_flow_access.identity_id
}

output "vnet_flow_identity_client_id" {
  description = "Client ID of the managed identity (for sensor configuration)"
  value       = module.vnet_flow_access.identity_client_id
}
