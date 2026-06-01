# Azure Enrichment IAM Submodule

Terraform submodule for creating the Azure managed identity, role assignments, and optionally the storage account and Service Bus required by the Corelight Cloud Enrichment module.

## Description

This submodule creates the necessary IAM resources for the enrichment Container App:

- **User Assigned Managed Identity**: The identity the Container App runs as
- **Custom Role Definition**: Grants minimal read permissions for VM/NIC metadata
- **Role Assignments**: Binds the identity to required permissions

Optionally, this submodule can also create:

- **Storage Account and Container**: For storing enrichment data (via storage submodule)
- **Service Bus Namespace and Queue**: For event notifications (via service_bus submodule)

## Usage

This submodule can be used in several ways depending on your needs.

### Option 1: Full Auto-Create (Recommended for standalone use)

Let the submodule create all required infrastructure:

```terraform
module "enrichment_infra" {
  source = "github.com/corelight/terraform//modules/azure/enrichment/submodules/iam?ref=v28.4.0-1"

  subscription_id     = "00000000-0000-0000-0000-000000000000"
  resource_group_name = "corelight-enrichment-rg"
  location            = "eastus"

  # Auto-create storage account
  auto_create_storage_account       = true
  enrichment_storage_account_name   = "corelightenrichment"

  # Auto-create service bus
  auto_create_service_bus = true

  tags = {
    Environment = "production"
  }
}
```

### Option 2: Bring Your Own Resources

Use existing storage account and service bus:

```terraform
module "enrichment_iam" {
  source = "github.com/corelight/terraform//modules/azure/enrichment/submodules/iam?ref=v28.4.0-1"

  subscription_id     = "00000000-0000-0000-0000-000000000000"
  resource_group_name = "corelight-enrichment-rg"
  location            = "eastus"

  # Use existing storage account
  enrichment_storage_account_name           = azurerm_storage_account.enrichment.name
  enrichment_storage_account_resource_group = azurerm_resource_group.enrichment.name

  # Use existing service bus queue
  service_bus_queue_id = azurerm_servicebus_queue.enrichment.id
}
```

### Option 3: Mixed (Auto-create some, provide others)

```terraform
module "enrichment_iam" {
  source = "github.com/corelight/terraform//modules/azure/enrichment/submodules/iam?ref=v28.4.0-1"

  subscription_id     = "00000000-0000-0000-0000-000000000000"
  resource_group_name = "corelight-enrichment-rg"
  location            = "eastus"

  # Auto-create storage account
  auto_create_storage_account     = true
  enrichment_storage_account_name = "corelightenrichment"

  # Use existing service bus queue
  service_bus_queue_id = azurerm_servicebus_queue.enrichment.id
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_location"></a> [location](#input\_location) | Azure location where resources will be deployed | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group where resources will be created | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | The ID (UUID) of the Azure Subscription where resources will be deployed | `string` | n/a | yes |
| <a name="input_app_identity_name"></a> [app\_identity\_name](#input\_app\_identity\_name) | The name of the user assigned identity which the Container App will run as | `string` | `"corelight-enrichment-user"` | no |
| <a name="input_auto_create_service_bus"></a> [auto\_create\_service\_bus](#input\_auto\_create\_service\_bus) | If true, creates a new Service Bus namespace and queue using the service\_bus submodule. If false, you must provide service\_bus\_queue\_id. | `bool` | `false` | no |
| <a name="input_auto_create_storage_account"></a> [auto\_create\_storage\_account](#input\_auto\_create\_storage\_account) | If true, creates a new storage account using the storage submodule. If false, you must provide enrichment\_storage\_account\_name and enrichment\_storage\_account\_resource\_group. | `bool` | `false` | no |
| <a name="input_enrichment_role_definition_name"></a> [enrichment\_role\_definition\_name](#input\_enrichment\_role\_definition\_name) | The name of the custom Corelight enrichment role definition | `string` | `"corelight-enrichment-role"` | no |
| <a name="input_enrichment_storage_account_container_name"></a> [enrichment\_storage\_account\_container\_name](#input\_enrichment\_storage\_account\_container\_name) | The name of the storage container for enrichment data. Used when auto\_create\_storage\_account is true. | `string` | `"enrichment"` | no |
| <a name="input_enrichment_storage_account_name"></a> [enrichment\_storage\_account\_name](#input\_enrichment\_storage\_account\_name) | The name of the storage account where enrichment data will be stored. Required when auto\_create\_storage\_account is false. When auto\_create\_storage\_account is true, this is the name for the new storage account. | `string` | `null` | no |
| <a name="input_enrichment_storage_account_resource_group"></a> [enrichment\_storage\_account\_resource\_group](#input\_enrichment\_storage\_account\_resource\_group) | The resource group of the storage account where enrichment data will be stored. Required when auto\_create\_storage\_account is false. | `string` | `null` | no |
| <a name="input_service_bus_namespace_name"></a> [service\_bus\_namespace\_name](#input\_service\_bus\_namespace\_name) | The name of the Service Bus namespace. Used when auto\_create\_service\_bus is true. | `string` | `"corelight-enrichment-state-change-bus"` | no |
| <a name="input_service_bus_queue_id"></a> [service\_bus\_queue\_id](#input\_service\_bus\_queue\_id) | The resource ID of the Service Bus queue that the identity needs access to. Required when auto\_create\_service\_bus is false. | `string` | `null` | no |
| <a name="input_service_bus_queue_name"></a> [service\_bus\_queue\_name](#input\_service\_bus\_queue\_name) | The name of the Service Bus queue. Used when auto\_create\_service\_bus is true. | `string` | `"corelight-enrichment-state-change-queue"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to created resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_enrichment_role_definition_id"></a> [enrichment\_role\_definition\_id](#output\_enrichment\_role\_definition\_id) | The ID of the custom Corelight enrichment role definition |
| <a name="output_enrichment_role_definition_name"></a> [enrichment\_role\_definition\_name](#output\_enrichment\_role\_definition\_name) | The name of the custom Corelight enrichment role definition |
| <a name="output_service_bus_namespace_fqdn"></a> [service\_bus\_namespace\_fqdn](#output\_service\_bus\_namespace\_fqdn) | The FQDN of the Service Bus namespace (only populated when auto\_create\_service\_bus is true) |
| <a name="output_service_bus_namespace_id"></a> [service\_bus\_namespace\_id](#output\_service\_bus\_namespace\_id) | The resource ID of the Service Bus namespace (only populated when auto\_create\_service\_bus is true) |
| <a name="output_service_bus_namespace_name"></a> [service\_bus\_namespace\_name](#output\_service\_bus\_namespace\_name) | The name of the Service Bus namespace (only populated when auto\_create\_service\_bus is true) |
| <a name="output_service_bus_queue_id"></a> [service\_bus\_queue\_id](#output\_service\_bus\_queue\_id) | The resource ID of the Service Bus queue (only populated when auto\_create\_service\_bus is true) |
| <a name="output_service_bus_queue_name"></a> [service\_bus\_queue\_name](#output\_service\_bus\_queue\_name) | The name of the Service Bus queue (only populated when auto\_create\_service\_bus is true) |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | The resource ID of the storage account (only populated when auto\_create\_storage\_account is true) |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | The name of the storage account (only populated when auto\_create\_storage\_account is true) |
| <a name="output_storage_container_name"></a> [storage\_container\_name](#output\_storage\_container\_name) | The name of the storage container (only populated when auto\_create\_storage\_account is true) |
| <a name="output_user_assigned_identity_client_id"></a> [user\_assigned\_identity\_client\_id](#output\_user\_assigned\_identity\_client\_id) | The client ID of the user assigned identity |
| <a name="output_user_assigned_identity_id"></a> [user\_assigned\_identity\_id](#output\_user\_assigned\_identity\_id) | The resource ID of the user assigned identity |
| <a name="output_user_assigned_identity_name"></a> [user\_assigned\_identity\_name](#output\_user\_assigned\_identity\_name) | The name of the user assigned identity |
| <a name="output_user_assigned_identity_principal_id"></a> [user\_assigned\_identity\_principal\_id](#output\_user\_assigned\_identity\_principal\_id) | The principal ID of the user assigned identity |
<!-- END_TF_DOCS -->
