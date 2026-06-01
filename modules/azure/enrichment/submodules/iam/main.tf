####################################################################################################
# Data Sources
####################################################################################################

data "azurerm_subscription" "subscription" {
  subscription_id = var.subscription_id
}

# Only look up storage account if not auto-creating
data "azurerm_storage_account" "enrichment_storage_account" {
  count = var.auto_create_storage_account ? 0 : 1

  name                = var.enrichment_storage_account_name
  resource_group_name = var.enrichment_storage_account_resource_group
}

####################################################################################################
# Conditionally create storage account using the storage submodule
####################################################################################################

module "storage" {
  source = "../storage"
  count  = var.auto_create_storage_account ? 1 : 0

  name                = var.enrichment_storage_account_name
  resource_group_name = var.resource_group_name
  location            = var.location
  container_name      = var.enrichment_storage_account_container_name

  tags = var.tags
}

####################################################################################################
# Conditionally create service bus using the service_bus submodule
####################################################################################################

module "service_bus" {
  source = "../service_bus"
  count  = var.auto_create_service_bus ? 1 : 0

  namespace_name      = var.service_bus_namespace_name
  queue_name          = var.service_bus_queue_name
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = var.tags
}

####################################################################################################
# Locals to unify access to resource IDs regardless of creation method
####################################################################################################

locals {
  # Storage account ID - either from the submodule or looked up via data source
  storage_account_id = var.auto_create_storage_account ? (
    module.storage[0].storage_account_id
  ) : data.azurerm_storage_account.enrichment_storage_account[0].id

  # Service bus queue ID - either from the submodule or provided variable
  service_bus_queue_id = var.auto_create_service_bus ? (
    module.service_bus[0].queue_id
  ) : var.service_bus_queue_id
}

####################################################################################################
# User Assigned Identity
####################################################################################################

resource "azurerm_user_assigned_identity" "app_identity" {
  name                = var.app_identity_name
  location            = var.location
  resource_group_name = var.resource_group_name
}

####################################################################################################
# Custom Role Definition for VM/NIC metadata access
####################################################################################################

resource "azurerm_role_definition" "enrichment_role_def" {
  name  = var.enrichment_role_definition_name
  scope = data.azurerm_subscription.subscription.id

  permissions {
    actions = [
      "Microsoft.Compute/virtualMachines/read",
      "Microsoft.Network/networkInterfaces/read",
      "Microsoft.Network/networkSecurityGroups/read",
      "Microsoft.Network/internalPublicIpAddresses/read"
    ]
  }
}

####################################################################################################
# Role Assignments
####################################################################################################

resource "azurerm_role_assignment" "enrichment_role_assignment" {
  principal_id         = azurerm_user_assigned_identity.app_identity.principal_id
  scope                = data.azurerm_subscription.subscription.id
  role_definition_name = azurerm_role_definition.enrichment_role_def.name
}

resource "azurerm_role_assignment" "service_bus_role_assignment" {
  principal_id         = azurerm_user_assigned_identity.app_identity.principal_id
  scope                = local.service_bus_queue_id
  role_definition_name = "Azure Service Bus Data Receiver"
}

resource "azurerm_role_assignment" "enrichment_storage_account_assignment" {
  principal_id         = azurerm_user_assigned_identity.app_identity.principal_id
  scope                = local.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
}
