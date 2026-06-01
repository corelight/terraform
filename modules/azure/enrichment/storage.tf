####################################################################################################
# Conditionally create storage account and container using the storage submodule
####################################################################################################

module "storage" {
  source = "./submodules/storage"
  count  = var.auto_create_enrichment_storage_account ? 1 : 0

  name                = var.enrichment_storage_account_name
  resource_group_name = var.resource_group_name
  location            = var.location
  container_name      = var.enrichment_storage_account_container_name

  tags = var.tags
}

####################################################################################################
# Locals to unify access to storage account details regardless of creation method
####################################################################################################

locals {
  # Storage account ID - either from the submodule or provided variable
  storage_account_id = var.auto_create_enrichment_storage_account ? (
    module.storage[0].storage_account_id
  ) : var.enrichment_storage_account_id

  # Storage account name - either from the submodule or extracted from the provided ID
  # Using coalesce to provide a fallback for tflint static analysis (validation ensures non-null at runtime)
  _storage_account_id_safe = coalesce(var.enrichment_storage_account_id, "/placeholder")
  storage_account_name = var.auto_create_enrichment_storage_account ? (
    module.storage[0].storage_account_name
  ) : element(split("/", local._storage_account_id_safe), length(split("/", local._storage_account_id_safe)) - 1)

  # Storage container name - either from the submodule or provided variable
  storage_container_name = var.auto_create_enrichment_storage_account ? (
    module.storage[0].storage_container_name
  ) : var.enrichment_storage_account_container
}
