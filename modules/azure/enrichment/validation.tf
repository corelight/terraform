locals {
  # Validation for storage account configuration
  validate_storage_auto_create = var.auto_create_enrichment_storage_account ? (
    var.enrichment_storage_account_name != null
  ) : true

  validate_storage_provided = !var.auto_create_enrichment_storage_account ? (
    var.enrichment_storage_account_id != null && var.enrichment_storage_account_container != null
  ) : true

  # Validation for service bus configuration
  validate_service_bus_provided = !var.auto_create_service_bus ? (
    var.service_bus_queue_id != null && var.service_bus_namespace_fqdn != null
  ) : true

  # Validation for IAM configuration
  validate_iam_provided = !var.auto_create_iam ? (
    var.app_identity_id != null && var.app_identity_client_id != null
  ) : true
}

resource "terraform_data" "validate_storage_config" {
  lifecycle {
    precondition {
      condition     = local.validate_storage_auto_create
      error_message = "When auto_create_enrichment_storage_account is true, enrichment_storage_account_name must be provided."
    }

    precondition {
      condition     = local.validate_storage_provided
      error_message = "When auto_create_enrichment_storage_account is false, both enrichment_storage_account_id and enrichment_storage_account_container must be provided."
    }
  }
}

resource "terraform_data" "validate_service_bus_config" {
  lifecycle {
    precondition {
      condition     = local.validate_service_bus_provided
      error_message = "When auto_create_service_bus is false, both service_bus_queue_id and service_bus_namespace_fqdn must be provided."
    }
  }
}

resource "terraform_data" "validate_iam_config" {
  lifecycle {
    precondition {
      condition     = local.validate_iam_provided
      error_message = "When auto_create_iam is false, both app_identity_id and app_identity_client_id must be provided."
    }
  }
}

