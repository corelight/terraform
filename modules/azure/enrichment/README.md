# Azure Enrichment

Corelight Cloud Enrichment on Azure: Container App + Service Bus + Storage that captures VM state-change events and writes metadata for sensors to consume.

## Usage

```hcl
module "enrichment" {
  source = "github.com/corelight/terraform//modules/azure/enrichment?ref=v28.4.0-1"

  subscription_id                        = "00000000-0000-0000-0000-000000000000"
  resource_group_name                    = "corelight-enrichment-rg"
  location                               = "eastus"
  event_grid_system_topic_name           = "corelight-enrichment-topic"
  event_grid_system_topic_resource_group = "corelight-enrichment-rg"

  auto_create_enrichment_storage_account = true
  enrichment_storage_account_name        = "corelightenrichment"
  auto_create_iam                        = true
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
| <a name="input_event_grid_system_topic_name"></a> [event\_grid\_system\_topic\_name](#input\_event\_grid\_system\_topic\_name) | The name of the event grid system topic | `string` | n/a | yes |
| <a name="input_event_grid_system_topic_resource_group"></a> [event\_grid\_system\_topic\_resource\_group](#input\_event\_grid\_system\_topic\_resource\_group) | The resource group of the event grid system topic | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure location where resources will be deployed | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group where resources will be deployed | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | The ID (UUID) of the Azure Subscription where resources will be deployed | `string` | n/a | yes |
| <a name="input_app_container_cpu"></a> [app\_container\_cpu](#input\_app\_container\_cpu) | The CPU allocated for the container | `number` | `0.25` | no |
| <a name="input_app_container_memory"></a> [app\_container\_memory](#input\_app\_container\_memory) | The memory allocated for the container | `string` | `"0.5Gi"` | no |
| <a name="input_app_container_name"></a> [app\_container\_name](#input\_app\_container\_name) | The name of the running enrichment container | `string` | `"corelightcloudenrichment"` | no |
| <a name="input_app_env_locations"></a> [app\_env\_locations](#input\_app\_env\_locations) | The Azure locations the Container App should collect cloud resource data | `list(string)` | <pre>[<br/>  "eastus",<br/>  "eastus2",<br/>  "southcentralus",<br/>  "westus2",<br/>  "westus3",<br/>  "australiaeast",<br/>  "southeastasia",<br/>  "northeurope",<br/>  "swedencentral",<br/>  "uksouth",<br/>  "westeurope",<br/>  "centralus",<br/>  "southafricanorth",<br/>  "centralindia",<br/>  "eastasia",<br/>  "japaneast",<br/>  "koreacentral",<br/>  "canadacentral",<br/>  "francecentral",<br/>  "germanywestcentral",<br/>  "italynorth",<br/>  "norwayeast",<br/>  "polandcentral",<br/>  "switzerlandnorth",<br/>  "uaenorth",<br/>  "brazilsouth",<br/>  "centraluseuap",<br/>  "israelcentral",<br/>  "qatarcentral"<br/>]</pre> | no |
| <a name="input_app_env_log_level"></a> [app\_env\_log\_level](#input\_app\_env\_log\_level) | The log level the Container App should run. Set to "debug" while troubleshooting for additional context and logs | `string` | `"info"` | no |
| <a name="input_app_env_object_prefix"></a> [app\_env\_object\_prefix](#input\_app\_env\_object\_prefix) | The prefix prepended to all objects written to the Azure storage account container | `string` | `"corelight"` | no |
| <a name="input_app_environment_name"></a> [app\_environment\_name](#input\_app\_environment\_name) | The name of the Container App Environment used by the Container App | `string` | `"corelight-app-env"` | no |
| <a name="input_app_identity_client_id"></a> [app\_identity\_client\_id](#input\_app\_identity\_client\_id) | The client ID of the user assigned identity for the Container App. Required when auto\_create\_iam is false. | `string` | `null` | no |
| <a name="input_app_identity_id"></a> [app\_identity\_id](#input\_app\_identity\_id) | The resource ID of the user assigned identity for the Container App. Required when auto\_create\_iam is false. | `string` | `null` | no |
| <a name="input_app_identity_name"></a> [app\_identity\_name](#input\_app\_identity\_name) | The name of the user assigned identity to create when auto\_create\_iam is true. | `string` | `"corelight-enrichment-user"` | no |
| <a name="input_app_log_retention"></a> [app\_log\_retention](#input\_app\_log\_retention) | How long the Container App should retain logs | `number` | `30` | no |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | The name of the enrichment Container App | `string` | `"corelight-cloud-enrichment"` | no |
| <a name="input_app_sku"></a> [app\_sku](#input\_app\_sku) | The enrichment Container App SKU | `string` | `"PerGB2018"` | no |
| <a name="input_auto_create_enrichment_storage_account"></a> [auto\_create\_enrichment\_storage\_account](#input\_auto\_create\_enrichment\_storage\_account) | If true, the module will create a storage account and container for enrichment data. If false, you must provide enrichment\_storage\_account\_id and enrichment\_storage\_account\_container. | `bool` | `false` | no |
| <a name="input_auto_create_iam"></a> [auto\_create\_iam](#input\_auto\_create\_iam) | If true, the module will create the managed identity and role assignments. If false, you must provide app\_identity\_id and app\_identity\_client\_id. | `bool` | `false` | no |
| <a name="input_auto_create_service_bus"></a> [auto\_create\_service\_bus](#input\_auto\_create\_service\_bus) | If true, the module will create a Service Bus namespace and queue. If false, you must provide service\_bus\_queue\_id and service\_bus\_namespace\_fqdn. | `bool` | `true` | no |
| <a name="input_enrichment_role_definition_name"></a> [enrichment\_role\_definition\_name](#input\_enrichment\_role\_definition\_name) | The name of the custom role definition to create when auto\_create\_iam is true. | `string` | `"corelight-enrichment-role"` | no |
| <a name="input_enrichment_storage_account_container"></a> [enrichment\_storage\_account\_container](#input\_enrichment\_storage\_account\_container) | The storage account container that will store the cloud resource data. Required when auto\_create\_enrichment\_storage\_account is false. | `string` | `null` | no |
| <a name="input_enrichment_storage_account_container_name"></a> [enrichment\_storage\_account\_container\_name](#input\_enrichment\_storage\_account\_container\_name) | The name of the storage container to create when auto\_create\_enrichment\_storage\_account is true. | `string` | `"enrichment"` | no |
| <a name="input_enrichment_storage_account_id"></a> [enrichment\_storage\_account\_id](#input\_enrichment\_storage\_account\_id) | The resource ID of the storage account where enrichment data will be centralized. Required when auto\_create\_enrichment\_storage\_account is false. | `string` | `null` | no |
| <a name="input_enrichment_storage_account_name"></a> [enrichment\_storage\_account\_name](#input\_enrichment\_storage\_account\_name) | The name of the storage account to create when auto\_create\_enrichment\_storage\_account is true. Must be globally unique, 3-24 characters, lowercase letters and numbers only. | `string` | `null` | no |
| <a name="input_event_grid_subscription_name"></a> [event\_grid\_subscription\_name](#input\_event\_grid\_subscription\_name) | The name of the EventGrid subscription on the System Topic | `string` | `"corelight-system-topic-sub"` | no |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | The name of the Corelight Azure enrichment application | `string` | `"corelight/sensor-enrichment-azure"` | no |
| <a name="input_image_tag"></a> [image\_tag](#input\_image\_tag) | The tag for the Corelight Azure enrichment application | `string` | `"latest"` | no |
| <a name="input_service_bus_name"></a> [service\_bus\_name](#input\_service\_bus\_name) | The name of the Service Bus namespace to create when auto\_create\_service\_bus is true. | `string` | `"corelight-enrichment-state-change-bus"` | no |
| <a name="input_service_bus_namespace_fqdn"></a> [service\_bus\_namespace\_fqdn](#input\_service\_bus\_namespace\_fqdn) | The FQDN of an existing Service Bus namespace (e.g., 'mybus.servicebus.windows.net'). Required when auto\_create\_service\_bus is false. | `string` | `null` | no |
| <a name="input_service_bus_queue_id"></a> [service\_bus\_queue\_id](#input\_service\_bus\_queue\_id) | The resource ID of an existing Service Bus queue. Required when auto\_create\_service\_bus is false. | `string` | `null` | no |
| <a name="input_service_bus_queue_name"></a> [service\_bus\_queue\_name](#input\_service\_bus\_queue\_name) | The Service Bus queue name. Used when auto\_create\_service\_bus is true, or to identify the queue name when auto\_create\_service\_bus is false. | `string` | `"corelight-enrichment-state-change-queue"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (optional) Any tags that should be applied to resources deployed by the module | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_app_identity_client_id"></a> [app\_identity\_client\_id](#output\_app\_identity\_client\_id) | The client ID of the user assigned identity (created or provided). |
| <a name="output_app_identity_id"></a> [app\_identity\_id](#output\_app\_identity\_id) | The resource ID of the user assigned identity (created or provided). |
| <a name="output_container_app_environment_name"></a> [container\_app\_environment\_name](#output\_container\_app\_environment\_name) | n/a |
| <a name="output_container_app_name"></a> [container\_app\_name](#output\_container\_app\_name) | n/a |
| <a name="output_enrichment_storage_account_id"></a> [enrichment\_storage\_account\_id](#output\_enrichment\_storage\_account\_id) | The resource ID of the enrichment storage account (created or provided). |
| <a name="output_enrichment_storage_account_name"></a> [enrichment\_storage\_account\_name](#output\_enrichment\_storage\_account\_name) | The name of the enrichment storage account (created or provided). |
| <a name="output_enrichment_storage_container_name"></a> [enrichment\_storage\_container\_name](#output\_enrichment\_storage\_container\_name) | The name of the enrichment storage container (created or provided). |
| <a name="output_event_grid_system_topic_subscription_name"></a> [event\_grid\_system\_topic\_subscription\_name](#output\_event\_grid\_system\_topic\_subscription\_name) | n/a |
| <a name="output_service_bus_namespace_fqdn"></a> [service\_bus\_namespace\_fqdn](#output\_service\_bus\_namespace\_fqdn) | The FQDN of the Service Bus namespace (created or provided). |
| <a name="output_service_bus_namespace_name"></a> [service\_bus\_namespace\_name](#output\_service\_bus\_namespace\_name) | The name of the Service Bus namespace (created or provided). |
| <a name="output_service_bus_queue_id"></a> [service\_bus\_queue\_id](#output\_service\_bus\_queue\_id) | The resource ID of the Service Bus queue (created or provided). |
| <a name="output_service_bus_queue_name"></a> [service\_bus\_queue\_name](#output\_service\_bus\_queue\_name) | The name of the Service Bus queue (created or provided). |
| <a name="output_workspace_log_analytics_workspace_name"></a> [workspace\_log\_analytics\_workspace\_name](#output\_workspace\_log\_analytics\_workspace\_name) | n/a |
<!-- END_TF_DOCS -->

For deployment guidance, sizing recommendations, troubleshooting, and architecture
details, see the official Corelight documentation.
