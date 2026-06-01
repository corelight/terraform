variable "project_id" {
  description = "GCP project to deploy Corelight enrichment resources"
  type        = string
}

variable "location" {
  description = "GCP location to deploy Corelight enrichment resources"
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
}

variable "organization_role_id" {
  description = "The organization role id granting access to enumerate folders and projects"
  type        = string
}

variable "service_account_display_name" {
  description = "The display name for the service account used by Corelight Enrichment"
  type        = string
  default     = "Corelight Enrichment"
}

# Variables with Defaults
variable "project_role_id" {
  description = "The ID of the role granting access to GCS"
  type        = string
  default     = "corelight_cloud_enrichment"
}

variable "project_role_title" {
  description = "The title of the role granting the Cloud Run Service Account access to cloud resources"
  type        = string
  default     = "Corelight Cloud Enrichment Role"
}

variable "scheduler_job_name" {
  description = "the name of the cloud scheduler job which initiates collection of all pertinent cloud resources"
  type        = string
  default     = "corelight-cloud-enrichment-scheduled"
}

variable "scheduler_job_cron" {
  description = "The cron expression used by the cloud scheduler job"
  type        = string
  default     = "*/15 * * * *"
}

variable "scheduler_job_time_zone" {
  description = "The time zone the cloud scheduled will run using"
  type        = string
  default     = "America/Chicago"
}

variable "scheduler_attempt_deadline" {
  description = "The timeout for the cloud scheduler job to get a response from the Cloud Run service"
  type        = string
  default     = "60s"
}

variable "cloud_run_image" {
  description = "The Corelight application image which gathers and stores cloud resource data in GCS"
  type        = string
  default     = "corelight/sensor-enrichment-gcp"
}

variable "cloud_run_image_tag" {
  description = "The version of the Corelight application to deploy"
  type        = string
  default     = "latest"
}

variable "cloud_run_log_level" {
  description = "The log level the cloud run service runs with. Set to \"debug\" if troubleshooting"
  type        = string
  default     = "info"
}

variable "cloud_run_bucket_object_prefix" {
  description = <<EOF
    The prefix prepended to every bucket object. Useful when storing data in a shared bucket.
    Must be in sync with the Corelight Cloud Enrichment configuration.
  EOF
  type        = string
  default     = "corelight"
}

variable "cloud_run_locations" {
  description = "The list of locations the Cloud Run service will look for applicable cloud resources"
  type        = list(string)
  default = [
    "asia-east1",
    "asia-east2",
    "asia-northeast1",
    "asia-northeast2",
    "asia-northeast3",
    "asia-south1",
    "asia-south2",
    "asia-southeast1",
    "asia-southeast2",
    "australia-southeast1",
    "australia-southeast2",
    "europe-central2",
    "europe-north1",
    "europe-southwest1",
    "europe-west1",
    "europe-west2",
    "europe-west3",
    "europe-west4",
    "europe-west6",
    "europe-west8",
    "europe-west9",
    "europe-west10",
    "europe-west12",
    "me-central1",
    "me-central2",
    "me-west1",
    "northamerica-northeast1",
    "northamerica-northeast2",
    "southamerica-east1",
    "southamerica-west1",
    "us-central1",
    "us-east1",
    "us-east4",
    "us-east5",
    "us-south1",
    "us-west1",
    "us-west2",
    "us-west3",
    "us-west4",
  ]
}


variable "cloud_run_service_name" {
  description = "The name of the Cloud Run service deployed to collect cloud resource data"
  type        = string
  default     = "corelight-cloud-enrichment"
}

variable "topic_name" {
  description = "The name of the PubSub topic fed by the Asset Folder Feed"
  type        = string
  default     = "corelight-cloud-enrichment"
}

variable "pubsub_subscription_name" {
  description = "The name of the PubSub subscription the Cloud Run service will use to keep cloud resource data up-to-date"
  type        = string
  default     = "corelight-cloud-enrichment-sub"
}

variable "cloud_asset_folder_feed_id" {
  description = "The name of the Asset Folder Feed which will inform the Cloud Run service when cloud resources have changed state"
  type        = string
  default     = "corelight-cloud-enrichment-folder-feed"
}

variable "message_retention_duration" {
  description = "How long the PubSub topic will retain cloud resource state change messages"
  type        = string
  default     = "86400s"
}

variable "labels" {
  description = "(optional) Any Labels you wish to add to all resources deployed by this module"
  type        = object({})
  default     = {}
}
