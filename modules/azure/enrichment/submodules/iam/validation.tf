####################################################################################################
# Variable Validation
# Using terraform_data with preconditions for cross-variable validation
####################################################################################################

locals {
  # Validation for storage account configuration
  validate_storage_auto_create = var.auto_create_storage_account ? (
    var.enrichment_storage_account_name != null
  ) : true

  validate_storage_provided = !var.auto_create_storage_account ? (
    var.enrichment_storage_account_name != null && var.enrichment_storage_account_resource_group != null
  ) : true

  # Validation for service bus configuration
  validate_service_bus_provided = !var.auto_create_service_bus ? (
    var.service_bus_queue_id != null
  ) : true
}

resource "terraform_data" "validate_storage_config" {
  lifecycle {
    precondition {
      condition     = local.validate_storage_auto_create
      error_message = "When auto_create_storage_account is true, enrichment_storage_account_name must be provided."
    }

    precondition {
      condition     = local.validate_storage_provided
      error_message = "When auto_create_storage_account is false, both enrichment_storage_account_name and enrichment_storage_account_resource_group must be provided."
    }
  }
}

resource "terraform_data" "validate_service_bus_config" {
  lifecycle {
    precondition {
      condition     = local.validate_service_bus_provided
      error_message = "When auto_create_service_bus is false, service_bus_queue_id must be provided."
    }
  }
}

