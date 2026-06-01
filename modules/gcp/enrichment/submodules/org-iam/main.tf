resource "google_organization_iam_custom_role" "enrichment_folder_enum_role" {
  org_id = var.organization_id
  permissions = [
    "resourcemanager.folders.list",
    "resourcemanager.folders.get",
    "resourcemanager.projects.list",
    "resourcemanager.projects.get",
    "compute.instances.list",
  ]
  role_id = var.custom_org_role_id
  title   = var.custom_org_role_title
}