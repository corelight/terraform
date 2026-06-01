resource "google_cloud_scheduler_job" "enrichment_collection_scheduler_job" {
  name             = var.scheduler_job_name
  project          = var.project_id
  region           = var.location
  description      = "Invoke Corelight Cloud Enrichment Synchronization"
  schedule         = var.scheduler_job_cron
  time_zone        = var.scheduler_job_time_zone
  attempt_deadline = var.scheduler_attempt_deadline

  http_target {
    http_method = "POST"
    uri         = "${google_cloud_run_v2_service.enrichment_service.uri}/scheduled"
    oidc_token {
      service_account_email = google_service_account.service_account.email
    }
  }

  depends_on = [
    google_project_service.services
  ]
}

