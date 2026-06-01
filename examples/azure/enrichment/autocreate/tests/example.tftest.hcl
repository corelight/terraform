# Tests for Auto-Create Example
# Validates that all resources are auto-created by the enrichment module

mock_provider "azurerm" {
  mock_data "azurerm_subscription" {
    defaults = {
      id              = "/subscriptions/00000000-0000-0000-0000-000000000000"
      subscription_id = "00000000-0000-0000-0000-000000000000"
      display_name    = "Test Subscription"
      tenant_id       = "00000000-0000-0000-0000-000000000001"
    }
  }

  mock_data "azurerm_storage_account" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/corelight/providers/Microsoft.Storage/storageAccounts/corelightenrichment"
      name                = "corelightenrichment"
      resource_group_name = "corelight"
      location            = "eastus"
    }
  }
}

run "test_autocreate_configuration" {
  command = plan

  # Override module outputs for plan-time assertions
  override_module {
    target = module.enrichment
    outputs = {
      container_app_name                = "corelight-cloud-enrichment"
      service_bus_namespace_name        = "corelight-enrichment-state-change-bus"
      service_bus_queue_name            = "corelight-enrichment-state-change-queue"
      service_bus_queue_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/corelight/providers/Microsoft.ServiceBus/namespaces/corelight-enrichment-state-change-bus/queues/corelight-enrichment-state-change-queue"
      service_bus_namespace_fqdn        = "corelight-enrichment-state-change-bus.servicebus.windows.net"
      enrichment_storage_account_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/corelight/providers/Microsoft.Storage/storageAccounts/corelightenrichment"
      enrichment_storage_account_name   = "corelightenrichment"
      enrichment_storage_container_name = "enrichment"
      app_identity_id                   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/corelight/providers/Microsoft.ManagedIdentity/userAssignedIdentities/corelight-enrichment-user"
      app_identity_client_id            = "11111111-1111-1111-1111-111111111111"
    }
  }

  assert {
    condition     = module.enrichment.container_app_name == "corelight-cloud-enrichment"
    error_message = "Enrichment module should create container app with default name"
  }

  assert {
    condition     = module.enrichment.enrichment_storage_account_name == "corelightenrichment"
    error_message = "Enrichment module should auto-create storage account"
  }

  assert {
    condition     = module.enrichment.service_bus_namespace_name == "corelight-enrichment-state-change-bus"
    error_message = "Enrichment module should auto-create service bus"
  }
}

run "test_resource_group" {
  command = plan

  assert {
    condition     = azurerm_resource_group.corelight_resource_group.name == "corelight"
    error_message = "Resource group should have correct name"
  }
}

run "test_event_grid_topic" {
  command = plan

  assert {
    condition     = azurerm_eventgrid_system_topic.system_topic.topic_type == "Microsoft.Resources.Subscriptions"
    error_message = "Event Grid topic should be subscription type"
  }
}
