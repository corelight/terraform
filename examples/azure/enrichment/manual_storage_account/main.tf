# Example: Manual Storage Account
# This example demonstrates deploying with manually created Storage Account,
# while service bus and IAM are auto-created by the enrichment module.

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

  name                = "manualstorage12345"
  resource_group_name = azurerm_resource_group.corelight_resource_group.name
  location            = local.deployment_location
  container_name      = "custom-enrichment"

  tags = local.tags
}

####################################################################################################
# Deploy the enrichment module with manual storage, auto-create service bus and IAM
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

  # Auto-create service bus (default)
  auto_create_service_bus = true

  # Auto-create IAM resources
  auto_create_iam = true

  tags = local.tags
}

