# Networking

variable "vpc_id" {
  description = "The ID of the VPC where resources will be deployed."
  type        = string
}

variable "public_subnets" {
  description = "List of subnet IDs where the ALB will be deployed."
  type        = list(string)
}

variable "private_subnet" {
  description = "The ID of the subnet where Fleet instance will be deployed."
  type        = string
}

variable "route53_zone_name" {
  description = "The Route53 hosted zone name (e.g., example.com.)."
  type        = string
}

variable "subdomain" {
  description = "Subdomain for Fleet to be prefixed to the hosted zone name (e.g., fleet)."
  type        = string
  default     = "fleet"
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS. Optional; if not provided, users will see a browser warning when accessing Fleet."
  type        = string
  default     = ""
}

variable "alb_security_group_id" {
  description = "Optional: Existing ALB security group ID to use"
  type        = string
  default     = null
}

variable "instance_security_group_id" {
  description = "Optional: Existing instance security group ID to use"
  type        = string
  default     = null
}

variable "alb_https_ingress_cidr_blocks" {
  description = "List of CIDR blocks allowed to access ALB on HTTPS (443)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "alb_api_ingress_cidr_blocks" {
  description = "List of CIDR blocks allowed to access Fleet API on port 1443"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "admin_cidr_blocks" {
  description = "List of CIDR blocks for admin access to Fleet instance (e.g., your home or office IP)."
  type        = list(string)
  default     = []
}

# EC2 Deployment

variable "aws_key_pair_name" {
  description = "The name of the AWS key pair for accessing Fleet instances."
  type        = string
}

variable "fleet_ami_id" {
  description = "Optional: AMI ID to use for Fleet instance. If not provided, the latest Ubuntu 22.04 LTS AMI will be used."
  type        = string
  default     = null
}

variable "aws_ec2_size" {
  description = "EC2 instance type/size. Follow documentation for Fleet to determine the appropriate size."
  type        = string
  default     = "t3.large"
}

variable "aws_volume_size" {
  description = "Root EBS volume size (GB)."
  type        = number
  default     = 50
}

# Fleet Configuration

variable "community_string" {
  description = "Fleet community string for sensor pairing."
  type        = string
}

variable "fleet_username" {
  description = "Fleet admin username."
  type        = string
}

variable "fleet_password" {
  description = "Fleet admin password."
  type        = string
  sensitive   = true
}

variable "fleet_certificate_file_path" {
  description = "Path to the Fleet certificate file."
  type        = string
}

variable "fleet_sensor_license_file_path" {
  description = "Path to the Fleet sensor license file."
  type        = string
}

variable "fleet_version" {
  description = "The version of Fleet to deploy."
  type        = string
  default     = "28.2.2"
}

# RADIUS Authentication

variable "radius_enable" {
  description = "Enable RADIUS authentication. Optional; if not set, RADIUS will not be configured."
  type        = bool
  default     = false
}

variable "radius_address" {
  description = "RADIUS server address and port (e.g., 1.2.3.4:1812). If RADIUS is enabled, this must be set."
  type        = string
  default     = ""
}

variable "radius_shared_secret" {
  description = "RADIUS shared secret. If RADIUS is enabled, this must be set."
  type        = string
  default     = ""
  sensitive   = true
}

# Naming Conventions

variable "fleet_instance_name" {
  description = "The Fleet instance name."
  type        = string
  default     = "corelight-fleet"
}

variable "fleet_alb_name" {
  description = "The name of the Fleet ALB."
  type        = string
  default     = "corelight-fleet-alb"
}

variable "fleet_lb_target_group_name" {
  description = "The name of the Fleet ALB target group."
  type        = string
  default     = "corelight-fleet-tg"
}

variable "fleet_alb_security_group_name" {
  description = "Name of the security group used by the ALB."
  type        = string
  default     = "corelight-fleet-alb-security-group"
}

variable "fleet_instance_security_group_name" {
  description = "Name of the security group used by the Fleet instance."
  type        = string
  default     = "corelight-fleet-instance-security-group"
}

# Tags are applied via provider default_tags configuration
# See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs#default_tags