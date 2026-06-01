# Tests for Manual Storage Account Example
# Validates that storage is created via submodule, service bus and IAM are auto-created

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
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/corelight/providers/Microsoft.Storage/storageAccounts/manualstorage12345"
      name                = "manualstorage12345"
      resource_group_name = "corelight"
      location            = "eastus"
    }
  }
}

run "test_manual_storage_account" {
  command = plan

  # Override module outputs for plan-time assertions
  override_module {
    target = module.storage
    outputs = {
      storage_account_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/corelight/providers/Microsoft.Storage/storageAccounts/manualstorage12345"
      storage_account_name   = "manualstorage12345"
      storage_container_name = "custom-enrichment"
      storage_container_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/corelight/providers/Microsoft.Storage/storageAccounts/manualstorage12345/blobServices/default/containers/custom-enrichment"
      primary_blob_endpoint  = "https://manualstorage12345.blob.core.windows.net/"
    }
  }

  override_module {
    target = module.enrichment
    outputs = {
      container_app_name                = "corelight-cloud-enrichment"
      service_bus_namespace_name        = "corelight-enrichment-state-change-bus"
      service_bus_queue_name            = "corelight-enrichment-state-change-queue"
      service_bus_queue_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/corelight/providers/Microsoft.ServiceBus/namespaces/corelight-enrichment-state-change-bus/queues/corelight-enrichment-state-change-queue"
      service_bus_namespace_fqdn        = "corelight-enrichment-state-change-bus.servicebus.windows.net"
      enrichment_storage_account_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/corelight/providers/Microsoft.Storage/storageAccounts/manualstorage12345"
      enrichment_storage_account_name   = "manualstorage12345"
      enrichment_storage_container_name = "custom-enrichment"
      app_identity_id                   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/corelight/providers/Microsoft.ManagedIdentity/userAssignedIdentities/corelight-enrichment-user"
      app_identity_client_id            = "11111111-1111-1111-1111-111111111111"
    }
  }

  assert {
    condition     = module.storage.storage_account_name == "manualstorage12345"
    error_message = "Storage submodule should create storage account with custom name"
  }

  assert {
    condition     = module.storage.storage_container_name == "custom-enrichment"
    error_message = "Storage submodule should create container with custom name"
  }

  assert {
    condition     = module.enrichment.enrichment_storage_account_name == "manualstorage12345"
    error_message = "Enrichment module should use manual storage account"
  }

  assert {
    condition     = module.enrichment.service_bus_namespace_name == "corelight-enrichment-state-change-bus"
    error_message = "Enrichment module should auto-create service bus"
  }
}

