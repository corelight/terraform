####################################################################################################
# Identity Outputs
####################################################################################################

output "user_assigned_identity_id" {
  description = "The resource ID of the user assigned identity"
  value       = azurerm_user_assigned_identity.app_identity.id
}

output "user_assigned_identity_client_id" {
  description = "The client ID of the user assigned identity"
  value       = azurerm_user_assigned_identity.app_identity.client_id
}

output "user_assigned_identity_principal_id" {
  description = "The principal ID of the user assigned identity"
  value       = azurerm_user_assigned_identity.app_identity.principal_id
}

output "user_assigned_identity_name" {
  description = "The name of the user assigned identity"
  value       = azurerm_user_assigned_identity.app_identity.name
}

####################################################################################################
# Role Definition Outputs
####################################################################################################

output "enrichment_role_definition_id" {
  description = "The ID of the custom Corelight enrichment role definition"
  value       = azurerm_role_definition.enrichment_role_def.id
}

output "enrichment_role_definition_name" {
  description = "The name of the custom Corelight enrichment role definition"
  value       = azurerm_role_definition.enrichment_role_def.name
}

####################################################################################################
# Storage Account Outputs (when auto-created)
####################################################################################################

output "storage_account_id" {
  description = "The resource ID of the storage account (only populated when auto_create_storage_account is true)"
  value       = var.auto_create_storage_account ? module.storage[0].storage_account_id : null
}

output "storage_account_name" {
  description = "The name of the storage account (only populated when auto_create_storage_account is true)"
  value       = var.auto_create_storage_account ? module.storage[0].storage_account_name : null
}

output "storage_container_name" {
  description = "The name of the storage container (only populated when auto_create_storage_account is true)"
  value       = var.auto_create_storage_account ? module.storage[0].storage_container_name : null
}

####################################################################################################
# Service Bus Outputs (when auto-created)
####################################################################################################

output "service_bus_namespace_id" {
  description = "The resource ID of the Service Bus namespace (only populated when auto_create_service_bus is true)"
  value       = var.auto_create_service_bus ? module.service_bus[0].namespace_id : null
}

output "service_bus_namespace_name" {
  description = "The name of the Service Bus namespace (only populated when auto_create_service_bus is true)"
  value       = var.auto_create_service_bus ? module.service_bus[0].namespace_name : null
}

output "service_bus_queue_id" {
  description = "The resource ID of the Service Bus queue (only populated when auto_create_service_bus is true)"
  value       = var.auto_create_service_bus ? module.service_bus[0].queue_id : null
}

output "service_bus_queue_name" {
  description = "The name of the Service Bus queue (only populated when auto_create_service_bus is true)"
  value       = var.auto_create_service_bus ? module.service_bus[0].queue_name : null
}

output "service_bus_namespace_fqdn" {
  description = "The FQDN of the Service Bus namespace (only populated when auto_create_service_bus is true)"
  value       = var.auto_create_service_bus ? module.service_bus[0].namespace_fqdn : null
}
