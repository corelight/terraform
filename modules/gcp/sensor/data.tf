# Fetch available zones in the specified region
data "google_compute_zones" "available" {
  project = var.project_id
  region  = var.region
  status  = "UP"
}

locals {
  # Use user-provided zones if specified, otherwise use all available zones in the region
  distribution_zones = length(var.zones) > 0 ? var.zones : data.google_compute_zones.available.names
}
