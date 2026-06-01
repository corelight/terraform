output "autoscaling_group_name" {
  description = "Name of the sensor auto-scaling group"
  value       = module.sensor.autoscaling_group_name
}

output "autoscaling_group_arn" {
  description = "ARN of the sensor auto-scaling group"
  value       = module.sensor.autoscaling_group_arn
}

output "load_balancer_id" {
  description = "ID of the Gateway Load Balancer"
  value       = module.sensor.load_balancer_id
}

output "load_balancer_listener_id" {
  description = "ID of the Gateway Load Balancer listener"
  value       = module.sensor.load_balancer_listener_id
}

output "management_security_group_id" {
  description = "Security group ID for sensor management traffic"
  value       = module.sensor.management_security_group_id
}

output "management_security_group_arn" {
  description = "Security group ARN for sensor management traffic"
  value       = module.sensor.management_security_group_arn
}

output "monitoring_security_group_id" {
  description = "Security group ID for sensor monitoring traffic"
  value       = module.sensor.monitoring_security_group_id
}

output "monitoring_security_group_arn" {
  description = "Security group ARN for sensor monitoring traffic"
  value       = module.sensor.monitoring_security_group_arn
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group for Lambda logs"
  value       = module.sensor.cloudwatch_log_group_arn
}

output "launch_template_id" {
  description = "ID of the sensor launch template"
  value       = module.sensor.launch_template_id
}

output "auto_scale_policy_id" {
  description = "ID of the auto-scaling policy"
  value       = module.sensor.auto_scale_policy_id
}
