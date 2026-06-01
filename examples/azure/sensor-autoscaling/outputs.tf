output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.sensor_rg.name
}

output "internal_load_balancer_name" {
  description = "Name of the internal load balancer"
  value       = module.sensor.internal_load_balancer_name
}

output "nat_gateway_name" {
  description = "Name of the NAT gateway"
  value       = module.sensor.nat_gateway_name
}

output "nat_gateway_public_ip_name" {
  description = "Name of the NAT gateway public IP"
  value       = module.sensor.nat_gateway_public_ip_name
}

output "sensor_identity_principal_id" {
  description = "Principal ID of the sensor VMSS managed identity"
  value       = module.sensor.sensor_identity_principal_id
}

output "sensor_scale_set_name" {
  description = "Name of the sensor scale set"
  value       = module.sensor.sensor_scale_set_name
}

output "sensor_load_balancer_management_frontend_ip_address" {
  description = "Management frontend IP address of the load balancer"
  value       = module.sensor.sensor_load_balancer_management_frontend_ip_address
}

output "sensor_load_balancer_monitoring_frontend_ip_address" {
  description = "Monitoring frontend IP address of the load balancer"
  value       = module.sensor.sensor_load_balancer_monitoring_frontend_ip_address
}

output "management_subnet_id" {
  description = "ID of the management subnet"
  value       = azurerm_subnet.management_subnet.id
}

output "monitoring_subnet_id" {
  description = "ID of the monitoring subnet"
  value       = azurerm_subnet.monitoring_subnet.id
}

