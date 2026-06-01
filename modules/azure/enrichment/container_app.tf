resource "azurerm_log_analytics_workspace" "enrichment_log_analytics" {
  name                = var.app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.app_sku
  retention_in_days   = var.app_log_retention

  tags = var.tags
}

resource "azurerm_container_app_environment" "enrichment_app_env" {
  name                       = var.app_environment_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.enrichment_log_analytics.id

  tags = var.tags
}

resource "azurerm_container_app" "enrichment_app" {
  name                         = var.app_name
  container_app_environment_id = azurerm_container_app_environment.enrichment_app_env.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type = "UserAssigned"
    identity_ids = [
      local.identity_id
    ]
  }

  template {
    min_replicas = 1
    container {
      name   = var.app_container_name
      image  = "docker.io/${var.image_name}:${var.image_tag}"
      cpu    = var.app_container_cpu
      memory = var.app_container_memory

      env {
        name  = "SUBSCRIPTION_ID"
        value = var.subscription_id
      }
      env {
        name  = "LOCATIONS"
        value = join(",", var.app_env_locations)
      }
      env {
        name  = "AZURE_STORAGE_ACCOUNT"
        value = local.storage_account_name
      }
      env {
        name  = "AZURE_CLIENT_ID"
        value = local.identity_client_id
      }
      env {
        name  = "CONTAINER_NAME"
        value = local.storage_container_name
      }
      env {
        name  = "PREFIX"
        value = var.app_env_object_prefix
      }
      env {
        name  = "SERVICE_BUS_NAMESPACE_FQDN"
        value = local.service_bus_namespace_fqdn
      }
      env {
        name  = "SERVICE_BUS_QUEUE_NAME"
        value = local.service_bus_queue_name
      }
      env {
        name  = "LOG_LEVEL"
        value = var.app_env_log_level
      }
    }
  }

  tags = var.tags
}
