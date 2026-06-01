####################################################################################################
# Conditionally create Service Bus namespace and queue using the service_bus submodule
####################################################################################################

module "service_bus" {
  source = "./submodules/service_bus"
  count  = var.auto_create_service_bus ? 1 : 0

  namespace_name      = var.service_bus_name
  queue_name          = var.service_bus_queue_name
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = var.tags
}

####################################################################################################
# Locals to unify access to Service Bus details regardless of creation method
####################################################################################################

locals {
  # Service Bus queue ID - either from the submodule or provided variable
  service_bus_queue_id = var.auto_create_service_bus ? (
    module.service_bus[0].queue_id
  ) : var.service_bus_queue_id

  # Service Bus namespace FQDN - either from the submodule or provided variable
  service_bus_namespace_fqdn = var.auto_create_service_bus ? (
    module.service_bus[0].namespace_fqdn
  ) : var.service_bus_namespace_fqdn

  # Service Bus queue name - either from the submodule or provided variable
  service_bus_queue_name = var.auto_create_service_bus ? (
    module.service_bus[0].queue_name
  ) : var.service_bus_queue_name

  # Service Bus namespace name - either from the submodule or extracted from FQDN
  service_bus_namespace_name = var.auto_create_service_bus ? (
    module.service_bus[0].namespace_name
  ) : split(".", coalesce(var.service_bus_namespace_fqdn, ""))[0]
}
