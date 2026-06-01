variable "vpc_id" {
  description = "VPC ID where resources will be deployed"
  type        = string
}

variable "monitoring_subnet_ids" {
  description = "List of subnet IDs for monitoring traffic (one per AZ)"
  type        = list(string)
}

variable "management_subnet_ids" {
  description = "List of subnet IDs for management traffic (one per AZ)"
  type        = list(string)
}

variable "sensor_ssh_key_pair_name" {
  description = "Name of the SSH key pair in AWS used to access sensor EC2 instances"
  type        = string
}

variable "sensor_ami_id" {
  description = "Corelight sensor AMI ID (request from your account executive)"
  type        = string
}

variable "license_key_file_path" {
  description = "Path to your Corelight sensor license key file"
  type        = string
  sensitive   = true
  default     = ""
}

variable "community_string" {
  description = "Community string (api password) for sensor management"
  type        = string
  sensitive   = true
}

variable "fleet_token" {
  description = "Fleet pairing token from the Fleet UI (optional)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "fleet_url" {
  description = "URL of the Fleet instance (optional)"
  type        = string
  default     = ""
}

variable "fleet_server_sslname" {
  description = "SSL hostname for the Fleet server (optional)"
  type        = string
  default     = ""
}

variable "deployment_name" {
  description = "Name prefix for all resources (used to avoid naming conflicts)"
  type        = string
  default     = "corelight-sensor"
}

variable "sensor_asg_name" {
  description = "Name of the Corelight sensor auto-scale group"
  type        = string
  default     = null
}

variable "sensor_instance_name" {
  description = "Name tag applied to EC2 instances launched by the auto-scale group"
  type        = string
  default     = null
}

variable "sensor_launch_template_name" {
  description = "Name of the launch template used by the auto-scaling group"
  type        = string
  default     = null
}

variable "sensor_asg_load_balancer_name" {
  description = "Name of the load balancer which fronts the auto-scale group"
  type        = string
  default     = null
}

variable "lb_health_check_target_group_name" {
  description = "Name of the health check target group"
  type        = string
  default     = null
}

# AWS Provider Configuration
variable "region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Tags to apply to all resources (via provider default_tags)"
  type        = map(string)
  default = {
    terraform = "true"
    purpose   = "Corelight"
  }
}
