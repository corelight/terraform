output "storage_account_id" {
  description = "The resource ID of the storage account."
  value       = azurerm_storage_account.this.id
}

output "storage_account_name" {
  description = "The name of the storage account."
  value       = azurerm_storage_account.this.name
}

output "storage_container_name" {
  description = "The name of the storage container."
  value       = azurerm_storage_container.this.name
}

output "storage_container_id" {
  description = "The resource ID of the storage container."
  value       = azurerm_storage_container.this.id
}

output "primary_blob_endpoint" {
  description = "The primary blob endpoint of the storage account."
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

