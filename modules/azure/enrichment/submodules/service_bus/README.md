# Azure Service Bus Submodule

Terraform submodule for creating an Azure Service Bus namespace and queue for Corelight Cloud Enrichment.

## Description

This submodule creates:

- **Service Bus Namespace**: The messaging namespace for event notifications
- **Service Bus Queue**: The queue that receives VM state change events

## Usage

```terraform
module "service_bus" {
  source = "github.com/corelight/terraform//modules/azure/enrichment/submodules/service_bus?ref=v28.4.0-1"

  resource_group_name = "corelight-enrichment-rg"
  location            = "eastus"

  # Optional: customize names
  namespace_name = "my-enrichment-bus"
  queue_name     = "my-state-change-queue"

  tags = {
    Environment = "production"
  }
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

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_location"></a> [location](#input\_location) | The Azure location where the Service Bus will be created. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group where the Service Bus will be created. | `string` | n/a | yes |
| <a name="input_minimum_tls_version"></a> [minimum\_tls\_version](#input\_minimum\_tls\_version) | The minimum TLS version for the Service Bus namespace. | `string` | `"1.2"` | no |
| <a name="input_namespace_name"></a> [namespace\_name](#input\_namespace\_name) | The name of the Service Bus namespace. | `string` | `"corelight-enrichment-state-change-bus"` | no |
| <a name="input_queue_name"></a> [queue\_name](#input\_queue\_name) | The name of the Service Bus queue. | `string` | `"corelight-enrichment-state-change-queue"` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | The SKU of the Service Bus namespace. | `string` | `"Standard"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the Service Bus resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_namespace_fqdn"></a> [namespace\_fqdn](#output\_namespace\_fqdn) | The fully qualified domain name of the Service Bus namespace. |
| <a name="output_namespace_id"></a> [namespace\_id](#output\_namespace\_id) | The resource ID of the Service Bus namespace. |
| <a name="output_namespace_name"></a> [namespace\_name](#output\_namespace\_name) | The name of the Service Bus namespace. |
| <a name="output_queue_id"></a> [queue\_id](#output\_queue\_id) | The resource ID of the Service Bus queue. |
| <a name="output_queue_name"></a> [queue\_name](#output\_queue\_name) | The name of the Service Bus queue. |
<!-- END_TF_DOCS -->
