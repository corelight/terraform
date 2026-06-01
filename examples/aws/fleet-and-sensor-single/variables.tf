# Common Configuration
variable "aws_key_pair_name" {
  description = "AWS key pair name for SSH access"
  type        = string
}

# Fleet Networking
variable "fleet_vpc_id" {
  description = "VPC where Fleet is deployed"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "private_subnet" {
  description = "Private subnet ID for Fleet instance"
  type        = string
}

variable "route53_zone_name" {
  description = "Route53 hosted zone name"
  type        = string
}

variable "subdomain" {
  description = "Subdomain for Fleet"
  type        = string
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS"
  type        = string
}

# Fleet Authentication
variable "community_string" {
  description = "Community string for sensor pairing"
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
  description = "Path to Fleet certificate file"
  type        = string
}

variable "fleet_sensor_license_file_path" {
  description = "Path to Fleet sensor license file"
  type        = string
}

# Fleet Optional Configuration
variable "alb_security_group_id" {
  description = "Existing ALB security group ID"
  type        = string
  default     = null
}

variable "instance_security_group_id" {
  description = "Existing instance security group ID"
  type        = string
  default     = null
}

variable "alb_https_ingress_cidr_blocks" {
  description = "CIDR blocks allowed to access ALB on HTTPS (443)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "alb_api_ingress_cidr_blocks" {
  description = "CIDR blocks allowed to access Fleet API on port 1443"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "admin_cidr_blocks" {
  description = "CIDR blocks for admin access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "fleet_ami_id" {
  description = "Optional: AMI ID to use for Fleet instance. If not provided, the latest Ubuntu 22.04 LTS AMI will be used"
  type        = string
  default     = null
}

variable "aws_ec2_size" {
  description = "EC2 instance type for Fleet"
  type        = string
  default     = "t3.large"
}

variable "aws_volume_size" {
  description = "Root EBS volume size for Fleet (GB)"
  type        = number
  default     = 50
}

variable "fleet_version" {
  description = "Fleet version to deploy"
  type        = string
  default     = "28.3.3"
}

variable "radius_enable" {
  description = "Enable RADIUS authentication"
  type        = bool
  default     = false
}

variable "radius_address" {
  description = "RADIUS server address and port"
  type        = string
  default     = ""
}

variable "radius_shared_secret" {
  description = "RADIUS shared secret"
  type        = string
  default     = ""
  sensitive   = true
}

variable "fleet_instance_name" {
  description = "Fleet instance name"
  type        = string
  default     = "corelight-fleet"
}

variable "fleet_alb_name" {
  description = "Fleet ALB name"
  type        = string
  default     = "corelight-fleet-alb"
}

variable "fleet_lb_target_group_name" {
  description = "Fleet ALB target group name"
  type        = string
  default     = "corelight-fleet-tg"
}

variable "fleet_alb_security_group_name" {
  description = "Fleet ALB security group name"
  type        = string
  default     = "corelight-fleet-alb-security-group"
}

variable "fleet_instance_security_group_name" {
  description = "Fleet instance security group name"
  type        = string
  default     = "corelight-fleet-instance-security-group"
}

# Sensor Configuration
variable "sensor_vpc_id" {
  description = "VPC where sensor is deployed"
  type        = string
}

variable "sensor_instance_name" {
  description = "Sensor instance name"
  type        = string
}

variable "corelight_sensor_ami_id" {
  description = "Corelight sensor AMI ID"
  type        = string
}

variable "management_subnet_id" {
  description = "Management subnet ID for sensor"
  type        = string
}

variable "monitoring_subnet_id" {
  description = "Monitoring subnet ID for sensor"
  type        = string
}

# Sensor Instance Configuration
variable "associate_public_ip_address" {
  description = "Associate public IP with management interface"
  type        = bool
  default     = false
}

# Sensor Optional Configuration
variable "custom_sensor_user_data" {
  description = "Custom user data for sensor"
  type        = string
  default     = ""
}

variable "management_interface_name" {
  description = "Management interface name"
  type        = string
  default     = "corelight-sensor-nic-management"
}

variable "monitoring_interface_name" {
  description = "Monitoring interface name"
  type        = string
  default     = "corelight-sensor-nic-monitoring"
}

variable "instance_type" {
  description = "Sensor instance type"
  type        = string
  default     = "c5.2xlarge"
}

variable "ebs_volume_size" {
  description = "Sensor EBS volume size (GB)"
  type        = number
  default     = 500
}

variable "sensor_management_security_group_name" {
  description = "Sensor management security group name"
  type        = string
  default     = "corelight-management-security-group"
}

variable "sensor_management_security_group_description" {
  description = "Sensor management security group description"
  type        = string
  default     = "management security group for the sensor which allows ssh"
}

variable "sensor_monitoring_security_group_name" {
  description = "Sensor monitoring security group name"
  type        = string
  default     = "corelight-monitoring-security-group"
}

variable "sensor_monitoring_security_group_description" {
  description = "Sensor monitoring security group description"
  type        = string
  default     = "monitoring security group for the sensor which allows ssh"
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
