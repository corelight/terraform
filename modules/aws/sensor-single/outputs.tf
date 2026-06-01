output "sensor_instance_id" {
  description = "EC2 instance ID of the sensor"
  value       = module.instance.instance_id
}

output "monitoring_interface_id" {
  description = "Network interface ID for monitoring traffic"
  value       = var.monitoring_interface_id == "" ? module.monitoring_interface[0].network_interface_id : var.monitoring_interface_id
}

output "management_interface_id" {
  description = "Network interface ID for management traffic"
  value       = var.management_interface_id == "" ? module.management_interface[0].network_interface_id : var.management_interface_id
}
