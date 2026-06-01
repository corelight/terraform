output "cloud_run_service_name" {
  value = google_cloud_run_v2_service.enrichment_service.name
}

output "cloud_scheduler_job_id" {
  value = google_cloud_scheduler_job.enrichment_collection_scheduler_job.id
}

output "pubsub_topic_name" {
  value = google_pubsub_topic.feed_output.name
}

output "pubsub_subscription_name" {
  value = google_pubsub_subscription.sub.name
}

output "project_service_account_id" {
  value = google_service_account.service_account.id
}

output "project_iam_role_id" {
  value = google_project_iam_custom_role.enrichment_project_role.id
}

output "enabled_services" {
  value = local.required_services
}




