# Example: Manual IAM
# This example demonstrates deploying with manually created IAM (identity and role assignments).
# The IAM submodule auto-creates both storage and service bus internally.

locals {
  subscription_id     = "12345" # Your Azure Subscription ID (UUID)
  resource_group_name = "corelight"
  deployment_location = "eastus"
  tags = {
    terraform = "true"
    example   = "true"
    purpose   = "Corelight"
  }
}

data "azurerm_subscription" "subscription" {
  subscription_id = local.subscription_id
}

####################################################################################################
# Create a new resource group
####################################################################################################
resource "azurerm_resource_group" "corelight_resource_group" {
  name     = local.resource_group_name
  location = local.deployment_location

  tags = local.tags
}

####################################################################################################
# Event Grid System Topic
####################################################################################################
resource "azurerm_eventgrid_system_topic" "system_topic" {
  location            = "Global"
  name                = "subscription-system-topic"
  resource_group_name = azurerm_resource_group.corelight_resource_group.name
  source_resource_id  = data.azurerm_subscription.subscription.id
  topic_type          = "Microsoft.Resources.Subscriptions"

  tags = local.tags
}

####################################################################################################
# Manually create IAM using the IAM submodule
# The IAM submodule auto-creates both storage and service bus
####################################################################################################
module "iam" {
  source = "../../../../modules/azure/enrichment/submodules/iam"

  subscription_id     = local.subscription_id
  resource_group_name = azurerm_resource_group.corelight_resource_group.name
  location            = local.deployment_location

  # Auto-create the storage account within the IAM submodule
  auto_create_storage_account               = true
  enrichment_storage_account_name           = "iammanualstor12345"
  enrichment_storage_account_container_name = "enrichment"

  # Auto-create the service bus within the IAM submodule
  auto_create_service_bus = true

  app_identity_name               = "manual-iam-identity"
  enrichment_role_definition_name = "manual-iam-role"

  tags = local.tags
}

####################################################################################################
# Deploy the enrichment module using resources from the IAM submodule
####################################################################################################
module "enrichment" {
  source = "../../../../modules/azure/enrichment"

  resource_group_name                    = azurerm_resource_group.corelight_resource_group.name
  event_grid_system_topic_name           = azurerm_eventgrid_system_topic.system_topic.name
  event_grid_system_topic_resource_group = azurerm_resource_group.corelight_resource_group.name
  location                               = local.deployment_location
  subscription_id                        = local.subscription_id

  # Use storage from IAM submodule
  auto_create_enrichment_storage_account = false
  enrichment_storage_account_id          = module.iam.storage_account_id
  enrichment_storage_account_container   = module.iam.storage_container_name

  # Use service bus from IAM submodule
  auto_create_service_bus    = false
  service_bus_queue_id       = module.iam.service_bus_queue_id
  service_bus_namespace_fqdn = module.iam.service_bus_namespace_fqdn
  service_bus_queue_name     = module.iam.service_bus_queue_name

  # Use manually created IAM
  auto_create_iam        = false
  app_identity_id        = module.iam.user_assigned_identity_id
  app_identity_client_id = module.iam.user_assigned_identity_client_id

  tags = local.tags
}
