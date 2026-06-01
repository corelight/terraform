# Example: Manual Service Bus
# This example demonstrates deploying with manually created Service Bus,
# while storage account and IAM are auto-created by the enrichment module.

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
# Deploy the enrichment module with manual service bus, auto-create storage and IAM
####################################################################################################
module "enrichment" {
  source = "../../../../modules/azure/enrichment"

  resource_group_name                    = azurerm_resource_group.corelight_resource_group.name
  event_grid_system_topic_name           = azurerm_eventgrid_system_topic.system_topic.name
  event_grid_system_topic_resource_group = azurerm_resource_group.corelight_resource_group.name
  location                               = local.deployment_location
  subscription_id                        = local.subscription_id

  # Auto-create storage account
  auto_create_enrichment_storage_account = true
  enrichment_storage_account_name        = "servicebusmanualstor"

  # Use manually created service bus
  auto_create_service_bus    = false
  service_bus_queue_id       = module.service_bus.queue_id
  service_bus_namespace_fqdn = module.service_bus.namespace_fqdn
  service_bus_queue_name     = module.service_bus.queue_name

  # Auto-create IAM resources
  auto_create_iam = true

  tags = local.tags
}

