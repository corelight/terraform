locals {
  required_services = [
    "cloudscheduler.googleapis.com",
    "run.googleapis.com",
    "pubsub.googleapis.com"
  ]
}

resource "google_project_service" "services" {
  for_each           = toset(local.required_services)
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}