output "instance_id" {
  description = "EC2 instance ID of the sensor"
  value       = module.sensor.sensor_instance_id
}

output "monitoring_interface_id" {
  description = "Network interface ID for monitoring traffic"
  value       = module.sensor.monitoring_interface_id
}

output "management_interface_id" {
  description = "Network interface ID for management traffic"
  value       = module.sensor.management_interface_id
}
