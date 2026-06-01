resource "google_cloud_run_v2_service" "enrichment_service" {
  name                = var.cloud_run_service_name
  project             = var.project_id
  location            = var.location
  deletion_protection = false
  ingress             = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  template {
    service_account = google_service_account.service_account.email
    containers {
      image = "${var.cloud_run_image}:${var.cloud_run_image_tag}"
      resources {
        limits = {
          cpu    = 1
          memory = "512Mi"
        }
      }
      ports {
        container_port = "8080"
      }
      env {
        name  = "REGIONS"
        value = join(",", var.cloud_run_locations)
      }
      env {
        name  = "BUCKET_NAME"
        value = var.enrichment_bucket_name
      }
      env {
        name  = "PREFIX"
        value = var.cloud_run_bucket_object_prefix
      }
      env {
        name  = "LOG_LEVEL"
        value = var.cloud_run_log_level
      }
      env {
        name  = "ROOT_FOLDER_ID"
        value = var.folder_id
      }
    }
  }

  depends_on = [google_project_service.services]

  labels = var.labels
}

