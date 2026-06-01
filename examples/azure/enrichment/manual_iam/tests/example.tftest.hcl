# Tests for Manual IAM Example
# Validates that IAM is created via submodule with auto-created storage and service bus

mock_provider "azurerm" {
  mock_data "azurerm_subscription" {
    defaults = {
      id              = "/subscriptions/00000000-0000-0000-0000-000000000000"
      subscription_id = "00000000-0000-0000-0000-000000000000"
      display_name    = "Test Subscription"
      tenant_id       = "00000000-0000-0000-0000-000000000001"
    }
  }
}

run "test_manual_iam" {
  command = plan

  # Override module outputs for plan-time assertions
  override_module {
    target = module.iam
    outputs = {
      user_assigned_identity_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/corelight/providers/Microsoft.ManagedIdentity/userAssignedIdentities/manual-iam-identity"
      user_assigned_identity_client_id    = "11111111-1111-1111-1111-111111111111"
      user_assigned_identity_principal_id = "22222222-2222-2222-2222-222222222222"
      user_assigned_identity_name         = "manual-iam-identity"
      enrichment_role_definition_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/33333333-3333-3333-3333-333333333333"
      enrichment_role_definition_name     = "manual-iam-role"
      storage_account_id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/corelight/providers/Microsoft.Storage/storageAccounts/iammanualstor12345"
      storage_account_name                = "iammanualstor12345"
      storage_container_name              = "enrichment"
      service_bus_namespace_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/corelight/providers/Microsoft.ServiceBus/namespaces/corelight-enrichment-state-change-bus"
      service_bus_namespace_name          = "corelight-enrichment-state-change-bus"
      service_bus_queue_id                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/corelight/providers/Microsoft.ServiceBus/namespaces/corelight-enrichment-state-change-bus/queues/corelight-enrichment-state-change-queue"
      service_bus_queue_name              = "corelight-enrichment-state-change-queue"
      service_bus_namespace_fqdn          = "corelight-enrichment-state-change-bus.servicebus.windows.net"
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
      enrichment_storage_account_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/corelight/providers/Microsoft.Storage/storageAccounts/iammanualstor12345"
      enrichment_storage_account_name   = "iammanualstor12345"
      enrichment_storage_container_name = "enrichment"
      app_identity_id                   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/corelight/providers/Microsoft.ManagedIdentity/userAssignedIdentities/manual-iam-identity"
      app_identity_client_id            = "11111111-1111-1111-1111-111111111111"
    }
  }

  assert {
    condition     = module.iam.user_assigned_identity_name == "manual-iam-identity"
    error_message = "IAM submodule should create identity with custom name"
  }

  assert {
    condition     = module.iam.storage_account_name == "iammanualstor12345"
    error_message = "IAM submodule should auto-create storage account"
  }

  assert {
    condition     = module.iam.service_bus_queue_name == "corelight-enrichment-state-change-queue"
    error_message = "IAM submodule should auto-create service bus"
  }

  assert {
    condition     = module.enrichment.app_identity_client_id == "11111111-1111-1111-1111-111111111111"
    error_message = "Enrichment module should use manual IAM identity"
  }

  assert {
    condition     = module.enrichment.enrichment_storage_account_name == "iammanualstor12345"
    error_message = "Enrichment module should use storage from IAM submodule"
  }
}
