####################################################################################################
# Configure the provider
####################################################################################################

provider "google" {
  project     = var.project_id
  credentials = file(var.credentials_file)
  region      = var.location
  zone        = var.zone
}

####################################################################################################
# Create organization-level IAM role for enrichment
####################################################################################################

module "enrichment_org_iam" {
  source = "../../../modules/gcp/enrichment/submodules/org-iam"

  organization_id    = var.organization_id
  custom_org_role_id = var.custom_org_role_id
}

####################################################################################################
# Deploy GCP enrichment service
####################################################################################################

module "enrichment" {
  source = "../../../modules/gcp/enrichment"

  location               = var.location
  project_id             = var.project_id
  enrichment_bucket_name = var.enrichment_bucket_name
  folder_id              = var.folder_id
  service_account_id     = var.service_account_id
  organization_role_id   = module.enrichment_org_iam.custom_org_role_id

  labels = var.labels
}
