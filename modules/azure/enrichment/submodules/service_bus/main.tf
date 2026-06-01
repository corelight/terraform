resource "azurerm_servicebus_namespace" "this" {
  location            = var.location
  name                = var.namespace_name
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  minimum_tls_version = var.minimum_tls_version

  network_rule_set {
    trusted_services_allowed = true
  }

  tags = var.tags
}

resource "azurerm_servicebus_queue" "this" {
  name         = var.queue_name
  namespace_id = azurerm_servicebus_namespace.this.id
}

