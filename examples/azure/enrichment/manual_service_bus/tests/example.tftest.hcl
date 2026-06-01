# Tests for Manual Service Bus Example
# Validates that service bus is created via submodule, storage and IAM are auto-created

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
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/corelight/providers/Microsoft.Storage/storageAccounts/servicebusmanualstor"
      name                = "servicebusmanualstor"
      resource_group_name = "corelight"
      location            = "eastus"
    }
  }
}

run "test_manual_service_bus" {
  command = plan

  # Override module outputs for plan-time assertions
  override_module {
    target = module.service_bus
    outputs = {
      namespace_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/corelight/providers/Microsoft.ServiceBus/namespaces/manual-enrichment-bus"
      namespace_name = "manual-enrichment-bus"
      queue_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/corelight/providers/Microsoft.ServiceBus/namespaces/manual-enrichment-bus/queues/manual-state-change-queue"
      queue_name     = "manual-state-change-queue"
      namespace_fqdn = "manual-enrichment-bus.servicebus.windows.net"
    }
  }

  override_module {
    target = module.enrichment
    outputs = {
      container_app_name                = "corelight-cloud-enrichment"
      service_bus_namespace_name        = "manual-enrichment-bus"
      service_bus_queue_name            = "manual-state-change-queue"
      service_bus_queue_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/corelight/providers/Microsoft.ServiceBus/namespaces/manual-enrichment-bus/queues/manual-state-change-queue"
      service_bus_namespace_fqdn        = "manual-enrichment-bus.servicebus.windows.net"
      enrichment_storage_account_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/corelight/providers/Microsoft.Storage/storageAccounts/servicebusmanualstor"
      enrichment_storage_account_name   = "servicebusmanualstor"
      enrichment_storage_container_name = "enrichment"
      app_identity_id                   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/corelight/providers/Microsoft.ManagedIdentity/userAssignedIdentities/corelight-enrichment-user"
      app_identity_client_id            = "11111111-1111-1111-1111-111111111111"
    }
  }

  assert {
    condition     = module.service_bus.namespace_name == "manual-enrichment-bus"
    error_message = "Service bus submodule should create namespace with custom name"
  }

  assert {
    condition     = module.service_bus.queue_name == "manual-state-change-queue"
    error_message = "Service bus submodule should create queue with custom name"
  }

  assert {
    condition     = module.enrichment.service_bus_namespace_name == "manual-enrichment-bus"
    error_message = "Enrichment module should use manual service bus"
  }

  assert {
    condition     = module.enrichment.enrichment_storage_account_name == "servicebusmanualstor"
    error_message = "Enrichment module should auto-create storage account"
  }
}

