resource "google_cloud_asset_folder_feed" "folder_feed" {
  billing_project = var.project_id
  folder          = var.folder_id
  feed_id         = var.cloud_asset_folder_feed_id
  content_type    = "RESOURCE"

  asset_types = [
    "compute.googleapis.com/Instance"
  ]

  feed_output_config {
    pubsub_destination {
      topic = google_pubsub_topic.feed_output.id
    }
  }
}

resource "google_pubsub_topic" "feed_output" {
  name                       = var.topic_name
  project                    = var.project_id
  message_retention_duration = var.message_retention_duration
  labels                     = var.labels
}

resource "google_pubsub_subscription" "sub" {
  name    = var.pubsub_subscription_name
  project = var.project_id
  topic   = google_pubsub_topic.feed_output.id

  push_config {
    push_endpoint = "${google_cloud_run_v2_service.enrichment_service.uri}/event"
    oidc_token {
      service_account_email = google_service_account.service_account.email
    }
    attributes = {
      x-goog-version = "v1"
    }
  }

  labels     = var.labels
  depends_on = [google_cloud_run_v2_service.enrichment_service]
}