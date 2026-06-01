# Example: Fully Manual
# This example demonstrates deploying with all resources created manually using submodules.
# Each component (storage, service bus, IAM) is explicitly created via its respective submodule.

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
# Manually create Storage Account using the storage submodule
####################################################################################################
module "storage" {
  source = "../../../../modules/azure/enrichment/submodules/storage"

  name                = "manualenrichstor123"
  resource_group_name = azurerm_resource_group.corelight_resource_group.name
  location            = local.deployment_location
  container_name      = "enrichment"

  tags = local.tags
}

####################################################################################################
# Manually create Service Bus using the service_bus submodule
####################################################################################################
module "service_bus" {
  source = "../../../../modules/azure/enrichment/submodules/service_bus"

  namespace_name      = "manual-enrichment-bus"
  queue_name          = "manual-state-change-queue"
  resource_group_name = azurerm_resource_group.corelight_resource_group.name
  location            = local.deployment_location

  tags = local.tags
}

####################################################################################################
# Manually create IAM using the IAM submodule
# Uses the storage and service bus created above
####################################################################################################
module "iam" {
  source = "../../../../modules/azure/enrichment/submodules/iam"

  subscription_id     = local.subscription_id
  resource_group_name = azurerm_resource_group.corelight_resource_group.name
  location            = local.deployment_location

  # Use the manually created storage account
  enrichment_storage_account_name           = module.storage.storage_account_name
  enrichment_storage_account_resource_group = azurerm_resource_group.corelight_resource_group.name

  # Use the manually created service bus
  service_bus_queue_id = module.service_bus.queue_id

  app_identity_name               = "manual-enrichment-identity"
  enrichment_role_definition_name = "manual-enrichment-role"

  tags = local.tags

  # Explicit dependency to ensure storage account exists before data source lookup
  depends_on = [module.storage]
}

####################################################################################################
# Deploy the enrichment module using the manually created resources
####################################################################################################
module "enrichment" {
  source = "../../../../modules/azure/enrichment"

  resource_group_name                    = azurerm_resource_group.corelight_resource_group.name
  event_grid_system_topic_name           = azurerm_eventgrid_system_topic.system_topic.name
  event_grid_system_topic_resource_group = azurerm_resource_group.corelight_resource_group.name
  location                               = local.deployment_location
  subscription_id                        = local.subscription_id

  # Use manually created storage account
  auto_create_enrichment_storage_account = false
  enrichment_storage_account_id          = module.storage.storage_account_id
  enrichment_storage_account_container   = module.storage.storage_container_name

  # Use manually created service bus
  auto_create_service_bus    = false
  service_bus_queue_id       = module.service_bus.queue_id
  service_bus_namespace_fqdn = module.service_bus.namespace_fqdn
  service_bus_queue_name     = module.service_bus.queue_name

  # Use manually created IAM
  auto_create_iam        = false
  app_identity_id        = module.iam.user_assigned_identity_id
  app_identity_client_id = module.iam.user_assigned_identity_client_id

  tags = local.tags
}
