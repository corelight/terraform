output "sensor_private_ips" {
  description = "Map of sensor name to management private IP"
  value       = { for name, sensor in module.sensors : name => sensor.sensor_private_ip_address }
}

output "sensor_vm_ids" {
  description = "Map of sensor name to VM resource ID"
  value       = { for name, sensor in module.sensors : name => sensor.sensor_vm_id }
}

output "load_balancer_frontend_ip" {
  description = "Frontend IP of the internal load balancer (point mirrored traffic here)"
  value       = azurerm_lb.sensors.frontend_ip_configuration[0].private_ip_address
}
