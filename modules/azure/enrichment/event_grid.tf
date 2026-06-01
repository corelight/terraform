resource "azurerm_eventgrid_system_topic_event_subscription" "event_subscription" {
  name                  = var.event_grid_subscription_name
  resource_group_name   = var.event_grid_system_topic_resource_group
  system_topic          = var.event_grid_system_topic_name
  event_delivery_schema = "CloudEventSchemaV1_0"

  advanced_filter {
    string_contains {
      key    = "Subject"
      values = ["/providers/Microsoft.Compute/virtualMachines/"]
    }
    string_in {
      key = "data.operationName"
      values = [
        "Microsoft.Compute/virtualMachines/start/action",
        "Microsoft.Compute/virtualMachines/deallocate/action"
      ]
    }
  }

  included_event_types = [
    "Microsoft.Resources.ResourceActionSuccess"
  ]

  service_bus_queue_endpoint_id = local.service_bus_queue_id
}

