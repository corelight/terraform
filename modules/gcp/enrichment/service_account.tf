resource "google_service_account" "service_account" {
  account_id   = var.service_account_id
  project      = var.project_id
  display_name = var.service_account_display_name
}

resource "google_folder_iam_binding" "folder_binding" {
  folder  = var.folder_id
  members = ["serviceAccount:${google_service_account.service_account.email}"]
  role    = var.organization_role_id
}

resource "google_storage_bucket_iam_member" "gcs_access" {
  bucket = var.enrichment_bucket_name
  member = "serviceAccount:${google_service_account.service_account.email}"
  role   = google_project_iam_custom_role.enrichment_project_role.name
}

resource "google_project_iam_custom_role" "enrichment_project_role" {
  project = var.project_id
  permissions = [
    "storage.objects.create",
    "storage.objects.delete",
    "storage.objects.list",
    "storage.objects.get",
    "run.executions.cancel",
    "run.jobs.run",
    "run.routes.invoke"
  ]
  role_id = var.project_role_id
  title   = var.project_role_title
}

resource "google_cloud_run_service_iam_binding" "enrichment_permissions" {
  role     = google_project_iam_custom_role.enrichment_project_role.name
  project  = var.project_id
  location = var.location
  service  = google_cloud_run_v2_service.enrichment_service.name
  members  = ["serviceAccount:${google_service_account.service_account.email}"]
}
