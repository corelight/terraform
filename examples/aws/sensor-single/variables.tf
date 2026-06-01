variable "deployment_name" {
  description = "Name prefix for all resources (used to avoid naming conflicts)"
  type        = string
  default     = "corelight-sensor"
}

variable "ami_id" {
  description = "Corelight sensor AMI ID"
  type        = string
}

variable "community_string" {
  description = "Community string (api password) for sensor management"
  type        = string
  sensitive   = true
}

variable "aws_key_pair_name" {
  description = "AWS SSH key pair name for EC2 instance access"
  type        = string
}

variable "license_key_file_path" {
  description = "Path to Corelight license key file"
  type        = string
  default     = ""
}

variable "monitoring_interface_subnet_id" {
  description = "Subnet ID for monitoring network interface"
  type        = string
}

variable "monitoring_security_group_vpc_id" {
  description = "VPC ID for monitoring security group"
  type        = string
}

variable "management_interface_subnet_id" {
  description = "Subnet ID for management network interface"
  type        = string
}

variable "management_interface_public_ip" {
  description = "Whether to associate a public IP with management interface"
  type        = bool
  default     = false
}

variable "management_security_group_vpc_id" {
  description = "VPC ID for management security group"
  type        = string
}

variable "ssh_allow_cidrs" {
  description = "CIDR blocks allowed to SSH to the sensor"
  type        = list(string)
  default     = []
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
