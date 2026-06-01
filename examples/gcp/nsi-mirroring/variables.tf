####################################################################################################
# GCP Project and Region
####################################################################################################

variable "project_id" {
  description = "GCP project ID for deploying Corelight sensor resources"
  type        = string
}

variable "region" {
  description = "GCP region for regional resources (e.g., 'us-west1')"
  type        = string
}

variable "zone" {
  description = "GCP zone for zonal resources (e.g., 'us-west1-a')"
  type        = string
}

variable "zones" {
  description = "List of zones to distribute sensors across. If empty, sensors are distributed across all available zones in the region."
  type        = list(string)
  default     = []
}

variable "credentials_file" {
  description = "Path to GCP credentials JSON file"
  type        = string
  default     = "~/.config/gcloud/application_default_credentials.json"
}

####################################################################################################
# Consumer Project: Network Configuration
####################################################################################################

variable "network_mgmt_name" {
  description = "Name for the management VPC network (defaults to sensor_network_name-mgmt)"
  type        = string
  default     = ""
}

variable "subnetwork_mgmt_name" {
  description = "Name for the management subnetwork"
  type        = string
  default     = "corelight-mgmt-subnet"
}

variable "subnetwork_mgmt_cidr" {
  description = "CIDR range for management subnetwork (e.g., '10.0.1.0/24')"
  type        = string
}

variable "sensor_network_name" {
  description = "Name for the sensor/monitoring VPC network where sensors receive mirrored traffic"
  type        = string
  default     = "corelight-sensor-network"
}

variable "subnetwork_mon_name" {
  description = "Name for the monitoring subnetwork"
  type        = string
  default     = "corelight-mon-subnet"
}

variable "subnetwork_mon_cidr" {
  description = "CIDR range for monitoring subnetwork (e.g., '10.0.2.0/24')"
  type        = string
}

variable "subnetwork_mon_gateway" {
  description = "Gateway address for the monitoring subnetwork (e.g., '10.0.2.1')"
  type        = string
}

####################################################################################################
# Consumer Project: Sensor Instance Configuration
####################################################################################################

variable "instance_size" {
  description = "GCP compute machine type for sensor instances"
  type        = string
  default     = "e2-standard-8"
}

variable "image" {
  description = "Corelight sensor image name or self_link"
  type        = string
}

variable "image_disk_size" {
  description = "Disk size for sensor instances in GB"
  type        = string
  default     = "500"
}

variable "instance_ssh_user" {
  description = "SSH username for sensor instances"
  type        = string
  default     = "ec2-user"
}

variable "instance_ssh_key_pub" {
  description = "Path to public SSH key file for sensor instances"
  type        = string
}

variable "sensor_service_account_email" {
  description = "Service account email for sensor instances (optional)"
  type        = string
  default     = ""
}

####################################################################################################
# Consumer Project: Fleet and License Configuration
####################################################################################################

variable "fleet_token" {
  description = "Pairing token from Fleet UI"
  type        = string
  sensitive   = true
}

variable "fleet_url" {
  description = "URL of the Fleet instance"
  type        = string
}

variable "fleet_server_sslname" {
  description = "SSL hostname for the Fleet server"
  type        = string
}

variable "community_string" {
  description = "Community string (API string) for Fleet"
  type        = string
  sensitive   = true
}

variable "license_key_file_path" {
  description = "Path to Corelight sensor license key file (optional if fleet_url configured)"
  type        = string
  sensitive   = true
  default     = ""

  validation {
    condition     = var.license_key_file_path != "" || var.fleet_url != ""
    error_message = "Either license_key_file_path or fleet_url must be configured."
  }
}

variable "fleet_http_proxy" {
  description = "HTTP proxy URL for Fleet traffic (optional)"
  type        = string
  default     = ""
}

variable "fleet_https_proxy" {
  description = "HTTPS proxy URL for Fleet traffic (optional)"
  type        = string
  default     = ""
}

variable "fleet_no_proxy" {
  description = "Hosts or domains to bypass proxy for Fleet traffic (optional)"
  type        = string
  default     = ""
}

####################################################################################################
# Consumer Project: MIG and Autoscaling
####################################################################################################

variable "instance_template_resource_name_prefix" {
  description = "Name prefix for instance template"
  type        = string
  default     = "corelight-mig-template-"
}

variable "instance_template_group_manager_resource_name" {
  description = "Name for the regional MIG manager"
  type        = string
  default     = "corelight-mig-manager"
}

variable "instance_template_group_manager_base_instance_name" {
  description = "Base instance name for instances in the MIG"
  type        = string
  default     = "corelight"
}

variable "region_autoscaler_resource_name" {
  description = "Name for the regional autoscaler"
  type        = string
  default     = "corelight-autoscaler"
}

variable "region_autoscaler_policy_min_replicas" {
  description = "Minimum number of sensor instances"
  type        = number
  default     = 1
}

variable "region_autoscaler_policy_max_replicas" {
  description = "Maximum number of sensor instances"
  type        = number
  default     = 3
}

variable "region_autoscaler_policy_cooldown_period" {
  description = "Cooldown period in seconds before collecting metrics from new instances"
  type        = number
  default     = 600
}

variable "region_autoscaler_policy_cpu_utilization_target" {
  description = "Target CPU utilization for autoscaling (0.0-1.0)"
  type        = number
  default     = 0.7
}

####################################################################################################
# Consumer Project: Load Balancer and Health Checks
####################################################################################################

variable "region_health_check_resource_name" {
  description = "Name for the regional health check"
  type        = string
  default     = "corelight-health-check"
}

variable "health_check_http_port" {
  description = "HTTP port for health check probes"
  type        = string
  default     = "41080"
}

variable "region_probe_source_ranges_cidr" {
  description = "GCP health check probe source ranges"
  type        = list(string)
  default     = ["130.211.0.0/22", "35.191.0.0/16"]
}

variable "firewall_resource_name" {
  description = "Name for the health check firewall rule"
  type        = string
  default     = "corelight-health-check-rule"
}

variable "region_backend_service_resource_name" {
  description = "Name for the ILB backend service"
  type        = string
  default     = "corelight-backend-service"
}

variable "forwarding_rule_resource_name" {
  description = "Name for the ILB forwarding rule"
  type        = string
  default     = "corelight-forwarding-rule"
}

####################################################################################################
# NSI Mirroring Resources
####################################################################################################

variable "mirroring_deployment_group_id" {
  description = "ID for the NSI mirroring deployment group"
  type        = string
  default     = "corelight-mirroring-deployment-group"
}

variable "mirroring_deployment_id" {
  description = "ID for the NSI mirroring deployment"
  type        = string
  default     = "corelight-mirroring-deployment"
}

variable "mirroring_endpoint_group_id" {
  description = "ID for the NSI mirroring endpoint group"
  type        = string
  default     = "corelight-mirroring-endpoint-group"
}

variable "mirroring_labels" {
  description = "Labels to apply to NSI mirroring resources"
  type        = map(string)
  default     = {}
}

####################################################################################################
# Producer Project: VPCs to Mirror
####################################################################################################

variable "mirrored_vpcs" {
  description = <<-EOT
    List of VPC networks to mirror traffic from. Each entry specifies a producer VPC.

    Fields:
    - network: VPC name or self_link (e.g., 'customer-vpc' or 'projects/PROJECT/global/networks/VPC')
    - project_id: (Optional) Project ID if VPC is in a different project. Defaults to var.project_id

    Example single VPC:
    mirrored_vpcs = [{
      network = "customer-vpc-1"
    }]

    Example cross-project:
    mirrored_vpcs = [
      { network = "customer-vpc-1", project_id = "customer-project-1" },
      { network = "customer-vpc-2", project_id = "customer-project-2" }
    ]
  EOT
  type = list(object({
    network    = string
    project_id = optional(string)
  }))
  default = []
}

####################################################################################################
# Producer Project: Security Profile Configuration
####################################################################################################

variable "organization_id" {
  description = "GCP Organization ID (numeric, e.g., '536691410123') for org-level security profiles"
  type        = string
  default     = ""
}

variable "security_profile_group_id" {
  description = "Full resource ID of org-level security profile group. Format: organizations/ORG_ID/locations/global/securityProfileGroups/GROUP_NAME. If empty, constructed from organization_id and mirroring_profile_group_name."
  type        = string
  default     = ""
}

variable "mirroring_profile_group_name" {
  description = "Name for the security profile group (used if security_profile_group_id not provided)"
  type        = string
  default     = "corelight-mirror-profile-group"
}

####################################################################################################
# Producer Project: Traffic Selection
####################################################################################################

variable "mirroring_src_ip_ranges" {
  description = "Source IP ranges to mirror for ingress traffic"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "mirroring_dest_ip_ranges" {
  description = "Destination IP ranges to mirror for egress traffic"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
