output "instance_id" {
  description = "EC2 instance ID of the flow sensor"
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

output "iam_role_arn" {
  description = "ARN of the flow sensor IAM role"
  value       = aws_iam_role.flow_sensor.arn
}

output "iam_role_name" {
  description = "Name of the flow sensor IAM role (use this when creating cross-account trust policies)"
  value       = aws_iam_role.flow_sensor.name
}

output "instance_profile_arn" {
  description = "ARN of the flow sensor IAM instance profile"
  value       = aws_iam_instance_profile.flow_sensor.arn
}
