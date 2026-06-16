output "identity_id" {
  description = "Resource ID of the user-assigned managed identity (for attaching to VMSS)"
  value       = azurerm_user_assigned_identity.vnet_flow.id
}

output "identity_client_id" {
  description = "Client ID of the managed identity (for Workload Identity or AZURE_CLIENT_ID)"
  value       = azurerm_user_assigned_identity.vnet_flow.client_id
}

output "identity_principal_id" {
  description = "Principal ID of the managed identity"
  value       = azurerm_user_assigned_identity.vnet_flow.principal_id
}
