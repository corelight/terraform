# Region Configuration

variable "primary_region" {
  description = "The primary AWS region where enrichment resources will be deployed"
  type        = string
  default     = "us-east-1"
}

# S3 Bucket Configuration

variable "bucket_name" {
  description = "Name of the S3 bucket for storing enrichment data"
  type        = string
}

# ECR Image Configuration

variable "ecr_repository_name" {
  description = "Name of the ECR repository (e.g., 'corelight/sensor-enrichment-aws')"
  type        = string
}

variable "image_name" {
  description = "ECR image URI for the enrichment Lambda (without tag)"
  type        = string
}

variable "image_tag" {
  description = "Tag of the ECR image for the enrichment Lambda"
  type        = string
}

# EventBridge Configuration

variable "secondary_rule_name" {
  description = "Name of the EventBridge rule for secondary regions"
  type        = string
}

# Network Configuration

variable "vpc_id" {
  description = "ID of the VPC where resources will be deployed"
  type        = string
}

variable "monitoring_subnet" {
  description = "ID of the subnet for sensor monitoring interface"
  type        = string
}

variable "management_subnet" {
  description = "ID of the subnet for sensor management interface"
  type        = string
}

# Sensor Configuration

variable "sensor_ssh_key_pair_name" {
  description = "Name of the SSH key pair in AWS used to access the sensor EC2 instances"
  type        = string
}

variable "sensor_ami_id" {
  description = "AMI ID for the Corelight sensor"
  type        = string
}

variable "license_key_file" {
  description = "Path to the Corelight sensor license file"
  type        = string
}

variable "community_string" {
  description = "Community string (password) for the sensor API"
  type        = string
  sensitive   = true
}

variable "sensor_asg_load_balancer_name" {
  description = "Name of the sensor load balancer"
  type        = string
  default     = "corelight-sensor-lb"
}

variable "lb_health_check_target_group_name" {
  description = "Name of the health check target group"
  type        = string
  default     = "corelight-sensor-gwlb-tg"
}

variable "sensor_monitoring_security_group_name" {
  description = "Name of the monitoring security group"
  type        = string
  default     = "corelight-sensor-monitoring"
}

variable "sensor_management_security_group_name" {
  description = "Name of the management security group"
  type        = string
  default     = "corelight-sensor-management"
}

variable "sensor_launch_template_name" {
  description = "Name of the sensor launch template"
  type        = string
  default     = "corelight-sensor-launch-template"
}

variable "lambda_role_name" {
  description = "Name of the Lambda IAM role"
  type        = string
  default     = "corelight-asg-sensor-nic-manager-lambda-role"
}

variable "lambda_function_name" {
  description = "Name of the ENI management Lambda function"
  type        = string
  default     = "corelight-asg-sensor-nic-manager"
}

variable "lambda_policy_name" {
  description = "Name of the Lambda IAM policy"
  type        = string
  default     = "corelight-asg-sensor-nic-manager-lambda-policy"
}

variable "primary_event_bus_name" {
  description = "Name of the primary EventBridge event bus"
  type        = string
  default     = "corelight-primary-event-bus"
}

# Fleet Configuration

variable "fleet_url" {
  description = "URL of the Fleet instance"
  type        = string
}

variable "fleet_token" {
  description = "Pairing token from the Fleet UI"
  type        = string
  sensitive   = true
}

variable "fleet_server_sslname" {
  description = "SSL hostname for the Fleet server"
  type        = string
}

# Region Configuration

variable "my_regions" {
  description = "List of AWS regions to scan for enrichment data"
  type        = list(string)
}

# Tags

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
