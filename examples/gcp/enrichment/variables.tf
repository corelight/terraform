variable "project_id" {
  description = "GCP project to deploy Corelight enrichment resources"
  type        = string
}

variable "location" {
  description = "GCP location to deploy Corelight enrichment resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone to deploy enrichment resources"
  type        = string
  default     = "us-central1-a"
}

variable "credentials_file" {
  description = "Path to the GCP service account credentials JSON file"
  type        = string
}

variable "organization_id" {
  description = "The GCP Organization ID"
  type        = string
}

variable "folder_id" {
  description = "GCP folder to watch for cloud resource state change events"
  type        = string
}

variable "enrichment_bucket_name" {
  description = "The GCS bucket where cloud enrichment data will be centrally stored"
  type        = string
}

variable "service_account_id" {
  description = "ID of the service account used for enrichment"
  type        = string
  default     = "enrichment-service-account"
}

variable "custom_org_role_id" {
  description = "The custom organization role ID for enrichment"
  type        = string
  default     = "corelight_enrichment_role"
}

variable "labels" {
  description = "Labels to add to all resources deployed by this module"
  type        = map(string)
  default = {
    terraform = true
    example   = true
    purpose   = "corelight"
  }
}
