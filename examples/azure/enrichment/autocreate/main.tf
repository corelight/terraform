# Example: Full Auto-Create
# This example demonstrates the simplest deployment where the enrichment module
# automatically creates all required resources: storage account, service bus, and IAM.

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
# There is only one system topic per Azure subscription. Create a new one or use the existing one
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
# Create a new resource group or re-use an existing one
####################################################################################################
resource "azurerm_resource_group" "corelight_resource_group" {
  name     = local.resource_group_name
  location = local.deployment_location

  tags = local.tags
}

####################################################################################################
# Deploy the Container App and its supporting infrastructure
# The module will automatically create storage account, service bus, and IAM resources
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
  enrichment_storage_account_name        = "corelightenrichment"

  # Auto-create service bus (default)
  auto_create_service_bus = true

  # Auto-create IAM resources
  auto_create_iam = true

  tags = local.tags
}

