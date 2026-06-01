output "workspace_log_analytics_workspace_name" {
  value = azurerm_log_analytics_workspace.enrichment_log_analytics.name
}

output "container_app_environment_name" {
  value = azurerm_container_app_environment.enrichment_app_env.name
}

output "container_app_name" {
  value = azurerm_container_app.enrichment_app.name
}

output "event_grid_system_topic_subscription_name" {
  value = azurerm_eventgrid_system_topic_event_subscription.event_subscription.name
}

output "service_bus_namespace_name" {
  description = "The name of the Service Bus namespace (created or provided)."
  value       = local.service_bus_namespace_name
}

output "service_bus_queue_name" {
  description = "The name of the Service Bus queue (created or provided)."
  value       = local.service_bus_queue_name
}

output "service_bus_queue_id" {
  description = "The resource ID of the Service Bus queue (created or provided)."
  value       = local.service_bus_queue_id
}

output "service_bus_namespace_fqdn" {
  description = "The FQDN of the Service Bus namespace (created or provided)."
  value       = local.service_bus_namespace_fqdn
}

output "enrichment_storage_account_id" {
  description = "The resource ID of the enrichment storage account (created or provided)."
  value       = local.storage_account_id
}

output "enrichment_storage_account_name" {
  description = "The name of the enrichment storage account (created or provided)."
  value       = local.storage_account_name
}

output "enrichment_storage_container_name" {
  description = "The name of the enrichment storage container (created or provided)."
  value       = local.storage_container_name
}

output "app_identity_id" {
  description = "The resource ID of the user assigned identity (created or provided)."
  value       = local.identity_id
}

output "app_identity_client_id" {
  description = "The client ID of the user assigned identity (created or provided)."
  value       = local.identity_client_id
}
