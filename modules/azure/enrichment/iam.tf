####################################################################################################
# Conditionally create IAM resources using the IAM submodule
####################################################################################################

module "iam" {
  source = "./submodules/iam"
  count  = var.auto_create_iam ? 1 : 0

  subscription_id     = var.subscription_id
  resource_group_name = var.resource_group_name
  location            = var.location

  # Use existing storage account (created by enrichment module or provided)
  auto_create_storage_account               = false
  enrichment_storage_account_name           = local.storage_account_name
  enrichment_storage_account_resource_group = var.resource_group_name

  # Use existing service bus (created by enrichment module or provided)
  auto_create_service_bus = false
  service_bus_queue_id    = local.service_bus_queue_id

  app_identity_name               = var.app_identity_name
  enrichment_role_definition_name = var.enrichment_role_definition_name

  tags = var.tags

  # Ensure storage and service bus are created before IAM module tries to use them
  depends_on = [module.storage, module.service_bus]
}

####################################################################################################
# Locals to unify access to identity details regardless of creation method
####################################################################################################

locals {
  # Identity ID - either from the submodule or provided variable
  identity_id = var.auto_create_iam ? (
    module.iam[0].user_assigned_identity_id
  ) : var.app_identity_id

  # Identity client ID - either from the submodule or provided variable
  identity_client_id = var.auto_create_iam ? (
    module.iam[0].user_assigned_identity_client_id
  ) : var.app_identity_client_id
}

