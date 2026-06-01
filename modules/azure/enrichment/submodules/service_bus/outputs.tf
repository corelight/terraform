output "namespace_id" {
  description = "The resource ID of the Service Bus namespace."
  value       = azurerm_servicebus_namespace.this.id
}

output "namespace_name" {
  description = "The name of the Service Bus namespace."
  value       = azurerm_servicebus_namespace.this.name
}

output "queue_id" {
  description = "The resource ID of the Service Bus queue."
  value       = azurerm_servicebus_queue.this.id
}

output "queue_name" {
  description = "The name of the Service Bus queue."
  value       = azurerm_servicebus_queue.this.name
}

output "namespace_fqdn" {
  description = "The fully qualified domain name of the Service Bus namespace."
  value       = "${azurerm_servicebus_namespace.this.name}.servicebus.windows.net"
}

