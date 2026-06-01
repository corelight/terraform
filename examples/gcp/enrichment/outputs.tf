output "cloud_run_service_name" {
  description = "The name of the Cloud Run service"
  value       = module.enrichment.cloud_run_service_name
}

output "cloud_scheduler_job_id" {
  description = "The ID of the Cloud Scheduler job"
  value       = module.enrichment.cloud_scheduler_job_id
}

output "pubsub_topic_name" {
  description = "The name of the Pub/Sub topic"
  value       = module.enrichment.pubsub_topic_name
}

output "pubsub_subscription_name" {
  description = "The name of the Pub/Sub subscription"
  value       = module.enrichment.pubsub_subscription_name
}

output "project_service_account_id" {
  description = "The ID of the service account used for enrichment"
  value       = module.enrichment.project_service_account_id
}

output "project_iam_role_id" {
  description = "The ID of the custom project IAM role"
  value       = module.enrichment.project_iam_role_id
}
