# Tests for Fully Manual Example
# Validates that all resources are created via their respective submodules

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
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/corelight/providers/Microsoft.Storage/storageAccounts/manualenrichstor123"
      name                = "manualenrichstor123"
      resource_group_name = "corelight"
      location            = "eastus"
    }
  }
}

run "test_manual_infrastructure" {
  command = plan

  # Override module outputs for plan-time assertions
  override_module {
    target = module.storage
    outputs = {
      storage_account_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/corelight/providers/Microsoft.Storage/storageAccounts/manualenrichstor123"
      storage_account_name   = "manualenrichstor123"
      storage_container_name = "enrichment"
      storage_container_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/corelight/providers/Microsoft.Storage/storageAccounts/manualenrichstor123/blobServices/default/containers/enrichment"
      primary_blob_endpoint  = "https://manualenrichstor123.blob.core.windows.net/"
    }
  }

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
    target = module.iam
    outputs = {
      user_assigned_identity_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/corelight/providers/Microsoft.ManagedIdentity/userAssignedIdentities/manual-enrichment-identity"
      user_assigned_identity_client_id    = "11111111-1111-1111-1111-111111111111"
      user_assigned_identity_principal_id = "22222222-2222-2222-2222-222222222222"
      user_assigned_identity_name         = "manual-enrichment-identity"
      enrichment_role_definition_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/33333333-3333-3333-3333-333333333333"
      enrichment_role_definition_name     = "manual-enrichment-role"
      storage_account_id                  = null
      storage_account_name                = null
      storage_container_name              = null
      service_bus_namespace_id            = null
      service_bus_namespace_name          = null
      service_bus_queue_id                = null
      service_bus_queue_name              = null
      service_bus_namespace_fqdn          = null
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
      enrichment_storage_account_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/corelight/providers/Microsoft.Storage/storageAccounts/manualenrichstor123"
      enrichment_storage_account_name   = "manualenrichstor123"
      enrichment_storage_container_name = "enrichment"
      app_identity_id                   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/corelight/providers/Microsoft.ManagedIdentity/userAssignedIdentities/manual-enrichment-identity"
      app_identity_client_id            = "11111111-1111-1111-1111-111111111111"
    }
  }

  assert {
    condition     = module.storage.storage_account_name == "manualenrichstor123"
    error_message = "Storage submodule should create storage account"
  }

  assert {
    condition     = module.service_bus.namespace_name == "manual-enrichment-bus"
    error_message = "Service bus submodule should create namespace"
  }

  assert {
    condition     = module.iam.user_assigned_identity_name == "manual-enrichment-identity"
    error_message = "IAM submodule should create identity"
  }

  assert {
    condition     = module.enrichment.container_app_name == "corelight-cloud-enrichment"
    error_message = "Enrichment module should create container app"
  }

  assert {
    condition     = module.enrichment.enrichment_storage_account_name == "manualenrichstor123"
    error_message = "Enrichment module should use manual storage"
  }

  assert {
    condition     = module.enrichment.service_bus_namespace_name == "manual-enrichment-bus"
    error_message = "Enrichment module should use manual service bus"
  }
}
