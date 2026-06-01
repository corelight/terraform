# Networking
variable "vpc_id" {
  description = "The ID of the VPC where resources will be deployed"
  type        = string
}

variable "public_subnets" {
  description = "List of subnet IDs where the ALB will be deployed"
  type        = list(string)
}

variable "private_subnet" {
  description = "The ID of the subnet where Fleet instance will be deployed"
  type        = string
}

variable "route53_zone_name" {
  description = "The Route53 hosted zone name (e.g., example.com.)"
  type        = string
}

variable "subdomain" {
  description = "Subdomain for Fleet to be prefixed to the hosted zone name"
  type        = string
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS"
  type        = string
}

# EC2 Configuration
variable "aws_key_pair_name" {
  description = "The name of the AWS key pair for accessing Fleet instances"
  type        = string
}

# Fleet Configuration
variable "community_string" {
  description = "Fleet community string for sensor pairing"
  type        = string
  sensitive   = true
}

variable "fleet_username" {
  description = "Fleet admin username"
  type        = string
}

variable "fleet_password" {
  description = "Fleet admin password"
  type        = string
  sensitive   = true
}

variable "fleet_certificate_file_path" {
  description = "Path to the Fleet certificate file"
  type        = string
}

variable "fleet_sensor_license_file_path" {
  description = "Path to the Fleet sensor license file"
  type        = string
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
  default     = {}
}
