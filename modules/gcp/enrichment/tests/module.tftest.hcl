# Unit tests for GCP Enrichment Module
# These tests validate the module configuration without deploying real infrastructure

mock_provider "google" {}

variables {
  project_id             = "test-project-123456"
  location               = "us-central1"
  zone                   = "us-central1-a"
  folder_id              = "123456789"
  enrichment_bucket_name = "test-enrichment-bucket"
  service_account_id     = "test-service-account"
  organization_role_id   = "test_org_role"
}

run "verify_cloud_run_service" {
  command = plan

  assert {
    condition     = google_cloud_run_v2_service.enrichment_service.name == "corelight-cloud-enrichment"
    error_message = "Cloud Run service name should default to 'corelight-cloud-enrichment'"
  }

  assert {
    condition     = google_cloud_run_v2_service.enrichment_service.location == "us-central1"
    error_message = "Cloud Run service should be in specified location"
  }

  assert {
    condition     = google_cloud_run_v2_service.enrichment_service.ingress == "INGRESS_TRAFFIC_INTERNAL_ONLY"
    error_message = "Cloud Run service should only accept internal traffic"
  }

  assert {
    condition     = google_cloud_run_v2_service.enrichment_service.template[0].containers[0].image == "corelight/sensor-enrichment-gcp:latest"
    error_message = "Cloud Run should use default enrichment image"
  }

  assert {
    condition     = google_cloud_run_v2_service.enrichment_service.template[0].containers[0].resources[0].limits["cpu"] == "1"
    error_message = "Cloud Run should have 1 CPU by default"
  }

  assert {
    condition     = google_cloud_run_v2_service.enrichment_service.template[0].containers[0].resources[0].limits["memory"] == "512Mi"
    error_message = "Cloud Run should have 512Mi memory by default"
  }
}

run "verify_cloud_run_environment_variables" {
  command = plan

  assert {
    condition     = contains([for env in google_cloud_run_v2_service.enrichment_service.template[0].containers[0].env : env.name], "REGIONS")
    error_message = "Cloud Run should have REGIONS environment variable"
  }

  assert {
    condition     = contains([for env in google_cloud_run_v2_service.enrichment_service.template[0].containers[0].env : env.name], "BUCKET_NAME")
    error_message = "Cloud Run should have BUCKET_NAME environment variable"
  }

  assert {
    condition     = contains([for env in google_cloud_run_v2_service.enrichment_service.template[0].containers[0].env : env.name], "PREFIX")
    error_message = "Cloud Run should have PREFIX environment variable"
  }

  assert {
    condition     = contains([for env in google_cloud_run_v2_service.enrichment_service.template[0].containers[0].env : env.name], "LOG_LEVEL")
    error_message = "Cloud Run should have LOG_LEVEL environment variable"
  }

  assert {
    condition     = contains([for env in google_cloud_run_v2_service.enrichment_service.template[0].containers[0].env : env.name], "ROOT_FOLDER_ID")
    error_message = "Cloud Run should have ROOT_FOLDER_ID environment variable"
  }

  assert {
    condition     = [for env in google_cloud_run_v2_service.enrichment_service.template[0].containers[0].env : env.value if env.name == "BUCKET_NAME"][0] == "test-enrichment-bucket"
    error_message = "BUCKET_NAME should be set correctly"
  }

  assert {
    condition     = [for env in google_cloud_run_v2_service.enrichment_service.template[0].containers[0].env : env.value if env.name == "PREFIX"][0] == "corelight"
    error_message = "PREFIX should default to 'corelight'"
  }

  assert {
    condition     = [for env in google_cloud_run_v2_service.enrichment_service.template[0].containers[0].env : env.value if env.name == "LOG_LEVEL"][0] == "info"
    error_message = "LOG_LEVEL should default to 'info'"
  }

  assert {
    condition     = [for env in google_cloud_run_v2_service.enrichment_service.template[0].containers[0].env : env.value if env.name == "ROOT_FOLDER_ID"][0] == "123456789"
    error_message = "ROOT_FOLDER_ID should be set correctly"
  }
}

run "verify_cloud_scheduler" {
  command = plan

  assert {
    condition     = google_cloud_scheduler_job.enrichment_collection_scheduler_job.name == "corelight-cloud-enrichment-scheduled"
    error_message = "Cloud Scheduler job should have default name"
  }

  assert {
    condition     = google_cloud_scheduler_job.enrichment_collection_scheduler_job.schedule == "*/15 * * * *"
    error_message = "Cloud Scheduler should run every 15 minutes by default"
  }

  assert {
    condition     = google_cloud_scheduler_job.enrichment_collection_scheduler_job.time_zone == "America/Chicago"
    error_message = "Cloud Scheduler should use America/Chicago timezone by default"
  }

  assert {
    condition     = google_cloud_scheduler_job.enrichment_collection_scheduler_job.attempt_deadline == "60s"
    error_message = "Cloud Scheduler should have 60s attempt deadline by default"
  }

  assert {
    condition     = google_cloud_scheduler_job.enrichment_collection_scheduler_job.http_target[0].http_method == "POST"
    error_message = "Cloud Scheduler should use POST method"
  }

  assert {
    condition     = length(google_cloud_scheduler_job.enrichment_collection_scheduler_job.http_target[0].oidc_token) > 0
    error_message = "Cloud Scheduler should have OIDC token configured"
  }
}

run "verify_pubsub_configuration" {
  command = plan

  assert {
    condition     = google_pubsub_topic.feed_output.name == "corelight-cloud-enrichment"
    error_message = "Pub/Sub topic should have default name"
  }

  assert {
    condition     = google_pubsub_topic.feed_output.message_retention_duration == "86400s"
    error_message = "Pub/Sub topic should retain messages for 24 hours by default"
  }

  assert {
    condition     = google_pubsub_subscription.sub.name == "corelight-cloud-enrichment-sub"
    error_message = "Pub/Sub subscription should have default name"
  }

  assert {
    condition     = length(google_pubsub_subscription.sub.push_config) > 0
    error_message = "Pub/Sub subscription should have push configuration"
  }

  assert {
    condition     = length(google_pubsub_subscription.sub.push_config[0].oidc_token) > 0
    error_message = "Pub/Sub subscription should have OIDC token configured"
  }
}

run "verify_service_account" {
  command = plan

  assert {
    condition     = google_service_account.service_account.account_id == "test-service-account"
    error_message = "Service account should use the provided service_account_id"
  }

  assert {
    condition     = google_service_account.service_account.display_name == "Corelight Enrichment"
    error_message = "Service account should have default display name"
  }
}

run "verify_asset_feed" {
  command = plan

  assert {
    condition     = google_cloud_asset_folder_feed.folder_feed.feed_id == "corelight-cloud-enrichment-folder-feed"
    error_message = "Asset feed should have default ID"
  }

  assert {
    condition     = google_cloud_asset_folder_feed.folder_feed.content_type == "RESOURCE"
    error_message = "Asset feed should track RESOURCE content type"
  }

  assert {
    condition     = contains(google_cloud_asset_folder_feed.folder_feed.asset_types, "compute.googleapis.com/Instance")
    error_message = "Asset feed should track compute instances"
  }

  assert {
    condition     = google_cloud_asset_folder_feed.folder_feed.folder == "123456789"
    error_message = "Asset feed should monitor the specified folder"
  }
}

run "verify_custom_names" {
  command = plan

  variables {
    cloud_run_service_name     = "custom-enrichment-service"
    topic_name                 = "custom-topic"
    pubsub_subscription_name   = "custom-subscription"
    scheduler_job_name         = "custom-scheduler"
    cloud_asset_folder_feed_id = "custom-feed"
    service_account_id         = "custom-service-account"
  }

  assert {
    condition     = google_cloud_run_v2_service.enrichment_service.name == "custom-enrichment-service"
    error_message = "Cloud Run service name should be customizable"
  }

  assert {
    condition     = google_service_account.service_account.account_id == "custom-service-account"
    error_message = "Service account ID should be customizable"
  }

  assert {
    condition     = google_pubsub_topic.feed_output.name == "custom-topic"
    error_message = "Pub/Sub topic name should be customizable"
  }

  assert {
    condition     = google_pubsub_subscription.sub.name == "custom-subscription"
    error_message = "Pub/Sub subscription name should be customizable"
  }

  assert {
    condition     = google_cloud_scheduler_job.enrichment_collection_scheduler_job.name == "custom-scheduler"
    error_message = "Scheduler job name should be customizable"
  }

  assert {
    condition     = google_cloud_asset_folder_feed.folder_feed.feed_id == "custom-feed"
    error_message = "Asset feed ID should be customizable"
  }
}

run "verify_custom_cloud_run_config" {
  command = plan

  variables {
    cloud_run_image                = "custom/enrichment-image"
    cloud_run_image_tag            = "v1.2.3"
    cloud_run_log_level            = "debug"
    cloud_run_bucket_object_prefix = "custom-prefix"
  }

  assert {
    condition     = google_cloud_run_v2_service.enrichment_service.template[0].containers[0].image == "custom/enrichment-image:v1.2.3"
    error_message = "Cloud Run image should be customizable"
  }

  assert {
    condition     = [for env in google_cloud_run_v2_service.enrichment_service.template[0].containers[0].env : env.value if env.name == "LOG_LEVEL"][0] == "debug"
    error_message = "LOG_LEVEL should be customizable"
  }

  assert {
    condition     = [for env in google_cloud_run_v2_service.enrichment_service.template[0].containers[0].env : env.value if env.name == "PREFIX"][0] == "custom-prefix"
    error_message = "PREFIX should be customizable"
  }
}

run "verify_custom_scheduler_config" {
  command = plan

  variables {
    scheduler_job_cron         = "0 */6 * * *"
    scheduler_job_time_zone    = "America/New_York"
    scheduler_attempt_deadline = "120s"
  }

  assert {
    condition     = google_cloud_scheduler_job.enrichment_collection_scheduler_job.schedule == "0 */6 * * *"
    error_message = "Cloud Scheduler cron should be customizable"
  }

  assert {
    condition     = google_cloud_scheduler_job.enrichment_collection_scheduler_job.time_zone == "America/New_York"
    error_message = "Cloud Scheduler timezone should be customizable"
  }

  assert {
    condition     = google_cloud_scheduler_job.enrichment_collection_scheduler_job.attempt_deadline == "120s"
    error_message = "Cloud Scheduler attempt deadline should be customizable"
  }
}

run "verify_custom_pubsub_config" {
  command = plan

  variables {
    message_retention_duration = "172800s"
  }

  assert {
    condition     = google_pubsub_topic.feed_output.message_retention_duration == "172800s"
    error_message = "Pub/Sub message retention should be customizable"
  }
}

run "verify_custom_regions" {
  command = plan

  variables {
    cloud_run_locations = ["us-east1", "us-west1", "europe-west1"]
  }

  assert {
    condition     = [for env in google_cloud_run_v2_service.enrichment_service.template[0].containers[0].env : env.value if env.name == "REGIONS"][0] == "us-east1,us-west1,europe-west1"
    error_message = "Cloud Run should have custom regions in REGIONS environment variable"
  }
}

run "verify_labels" {
  command = plan

  variables {
    labels = {
      environment = "test"
      team        = "security"
    }
  }

  assert {
    condition     = can(google_cloud_run_v2_service.enrichment_service.labels)
    error_message = "Labels attribute should be present on Cloud Run service"
  }

  assert {
    condition     = can(google_pubsub_topic.feed_output.labels)
    error_message = "Labels attribute should be present on Pub/Sub topic"
  }

  assert {
    condition     = can(google_pubsub_subscription.sub.labels)
    error_message = "Labels attribute should be present on Pub/Sub subscription"
  }
}
