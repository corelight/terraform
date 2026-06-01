# Storage Submodule

Terraform submodule for creating an Azure Storage Account and Container for Corelight enrichment data.

## Description

This submodule creates:

- **Storage Account**: Standard LRS storage account for enrichment data
- **Storage Container**: Private container for storing cloud resource metadata

## Usage

```terraform
module "enrichment_storage" {
  source = "github.com/corelight/terraform//modules/azure/enrichment/submodules/storage?ref=v28.4.0-1"

  name                = "corelightenrichment"
  resource_group_name = azurerm_resource_group.enrichment.name
  location            = "eastus"
  container_name      = "enrichment"

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
| <a name="input_location"></a> [location](#input\_location) | The Azure location where the storage account will be created. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the storage account. Must be globally unique, 3-24 characters, lowercase letters and numbers only. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group where the storage account will be created. | `string` | n/a | yes |
| <a name="input_account_replication_type"></a> [account\_replication\_type](#input\_account\_replication\_type) | The replication type of the storage account. | `string` | `"LRS"` | no |
| <a name="input_account_tier"></a> [account\_tier](#input\_account\_tier) | The tier of the storage account. | `string` | `"Standard"` | no |
| <a name="input_container_access_type"></a> [container\_access\_type](#input\_container\_access\_type) | The access type for the storage container. | `string` | `"private"` | no |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | The name of the storage container to create. | `string` | `"enrichment"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the storage account. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_primary_blob_endpoint"></a> [primary\_blob\_endpoint](#output\_primary\_blob\_endpoint) | The primary blob endpoint of the storage account. |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | The resource ID of the storage account. |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | The name of the storage account. |
| <a name="output_storage_container_id"></a> [storage\_container\_id](#output\_storage\_container\_id) | The resource ID of the storage container. |
| <a name="output_storage_container_name"></a> [storage\_container\_name](#output\_storage\_container\_name) | The name of the storage container. |
<!-- END_TF_DOCS -->
