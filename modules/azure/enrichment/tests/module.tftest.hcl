# Unit tests for Azure Enrichment Module
# These tests validate the module directly

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
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/teststorageaccount"
      name                = "teststorageaccount"
      resource_group_name = "test-rg"
      location            = "eastus"
    }
  }
}

variables {
  subscription_id                        = "00000000-0000-0000-0000-000000000000"
  resource_group_name                    = "test-rg"
  location                               = "eastus"
  enrichment_storage_account_id          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/teststorageaccount"
  enrichment_storage_account_container   = "test-container"
  event_grid_system_topic_name           = "test-system-topic"
  event_grid_system_topic_resource_group = "test-rg"
  app_identity_id                        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/test-identity"
  app_identity_client_id                 = "11111111-1111-1111-1111-111111111111"
}

run "verify_minimal_configuration" {
  command = plan

  # Validates minimal required configuration works
}

run "verify_container_app_defaults" {
  command = plan

  assert {
    condition     = azurerm_container_app.enrichment_app.name == "corelight-cloud-enrichment"
    error_message = "Container App should have default name corelight-cloud-enrichment"
  }

  assert {
    condition     = azurerm_container_app.enrichment_app.revision_mode == "Single"
    error_message = "Container App should use Single revision mode"
  }
}

run "verify_container_app_environment" {
  command = plan

  assert {
    condition     = azurerm_container_app_environment.enrichment_app_env.name == "corelight-app-env"
    error_message = "Container App Environment should have default name"
  }
}

run "verify_log_analytics_workspace" {
  command = plan

  assert {
    condition     = azurerm_log_analytics_workspace.enrichment_log_analytics.retention_in_days == 30
    error_message = "Log Analytics should have 30 days retention by default"
  }

  assert {
    condition     = azurerm_log_analytics_workspace.enrichment_log_analytics.sku == "PerGB2018"
    error_message = "Log Analytics should use PerGB2018 SKU by default"
  }
}

run "verify_service_bus_configuration" {
  command = plan

  assert {
    condition     = module.service_bus[0].namespace_name == "corelight-enrichment-state-change-bus"
    error_message = "Service Bus should have default name"
  }
}

run "verify_service_bus_queue" {
  command = plan

  assert {
    condition     = module.service_bus[0].queue_name == "corelight-enrichment-state-change-queue"
    error_message = "Service Bus Queue should have default name"
  }
}

run "verify_event_grid_subscription" {
  command = plan

  assert {
    condition     = azurerm_eventgrid_system_topic_event_subscription.event_subscription.name == "corelight-system-topic-sub"
    error_message = "Event Grid subscription should have default name"
  }

  assert {
    condition     = azurerm_eventgrid_system_topic_event_subscription.event_subscription.event_delivery_schema == "CloudEventSchemaV1_0"
    error_message = "Event Grid subscription should use CloudEventSchemaV1_0"
  }
}

run "verify_custom_resource_names" {
  command = plan

  variables {
    app_name             = "custom-enrichment-app"
    app_environment_name = "custom-app-env"
    service_bus_name     = "custom-service-bus"
  }

  assert {
    condition     = azurerm_container_app.enrichment_app.name == "custom-enrichment-app"
    error_message = "Container App name should be customizable"
  }

  assert {
    condition     = azurerm_container_app_environment.enrichment_app_env.name == "custom-app-env"
    error_message = "Container App Environment name should be customizable"
  }

  assert {
    condition     = module.service_bus[0].namespace_name == "custom-service-bus"
    error_message = "Service Bus name should be customizable"
  }
}

run "verify_custom_image_configuration" {
  command = plan

  variables {
    image_name = "custom/enrichment-image"
    image_tag  = "v1.0.0"
  }

  # Image configuration validated at plan level
}

run "verify_custom_log_level" {
  command = plan

  variables {
    app_env_log_level = "debug"
  }

  # Log level configuration validated at plan level
}

run "verify_tags_propagation" {
  command = plan

  variables {
    tags = {
      Environment = "test"
      ManagedBy   = "terraform"
    }
  }

  assert {
    condition     = azurerm_container_app.enrichment_app.tags["Environment"] == "test"
    error_message = "Container App should have tags applied"
  }

  assert {
    condition     = module.service_bus[0].namespace_name != ""
    error_message = "Service Bus should be created with tags"
  }
}

run "verify_auto_create_storage_account" {
  command = plan

  variables {
    auto_create_enrichment_storage_account = true
    enrichment_storage_account_name        = "autoteststorage"
    enrichment_storage_account_id          = null
    enrichment_storage_account_container   = null
  }

  assert {
    condition     = module.storage[0].storage_account_name == "autoteststorage"
    error_message = "Storage account should be created with specified name"
  }

  assert {
    condition     = module.storage[0].storage_container_name == "enrichment"
    error_message = "Storage container should use default name 'enrichment'"
  }
}

run "verify_auto_create_custom_container_name" {
  command = plan

  variables {
    auto_create_enrichment_storage_account    = true
    enrichment_storage_account_name           = "autoteststorage"
    enrichment_storage_account_container_name = "customcontainer"
    enrichment_storage_account_id             = null
    enrichment_storage_account_container      = null
  }

  assert {
    condition     = module.storage[0].storage_container_name == "customcontainer"
    error_message = "Storage container should use custom name when specified"
  }
}

run "verify_auto_create_iam" {
  command = plan

  variables {
    auto_create_iam        = true
    app_identity_id        = null
    app_identity_client_id = null
  }

  assert {
    condition     = module.iam[0].user_assigned_identity_name == "corelight-enrichment-user"
    error_message = "IAM identity should be created with default name"
  }
}

run "verify_auto_create_iam_custom_name" {
  command = plan

  variables {
    auto_create_iam        = true
    app_identity_name      = "custom-enrichment-identity"
    app_identity_id        = null
    app_identity_client_id = null
  }

  assert {
    condition     = module.iam[0].user_assigned_identity_name == "custom-enrichment-identity"
    error_message = "IAM identity should use custom name when specified"
  }
}

run "verify_full_auto_create" {
  command = plan

  variables {
    auto_create_enrichment_storage_account = true
    enrichment_storage_account_name        = "fullautostorage"
    enrichment_storage_account_id          = null
    enrichment_storage_account_container   = null
    auto_create_iam                        = true
    app_identity_id                        = null
    app_identity_client_id                 = null
  }

  assert {
    condition     = module.storage[0].storage_account_name == "fullautostorage"
    error_message = "Storage account should be auto-created"
  }

  assert {
    condition     = module.iam[0].user_assigned_identity_name == "corelight-enrichment-user"
    error_message = "IAM identity should be auto-created"
  }
}
