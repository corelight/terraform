# VNet Flow Storage Access Module

Creates a user-assigned Managed Identity with `Storage Blob Data Reader` access to a storage account containing Azure VNet Flow Logs.

## Usage

```hcl
module "vnet_flow_storage_access" {
  source = "./submodules/vnet_flow_storage_access"

  resource_group_name = "my-resource-group"
  location            = "eastus"
  storage_account_id  = "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.Storage/storageAccounts/vnetflowlogs"
}
```

Attach the identity to your VMSS and use the `identity_client_id` output for the sensor's VPC flow service configuration.

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
| <a name="input_location"></a> [location](#input\_location) | The Azure region for the managed identity | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The resource group where the managed identity will be created | `string` | n/a | yes |
| <a name="input_storage_account_id"></a> [storage\_account\_id](#input\_storage\_account\_id) | The resource ID of the storage account containing VNet flow logs | `string` | n/a | yes |
| <a name="input_identity_name"></a> [identity\_name](#input\_identity\_name) | Name of the user-assigned managed identity for VNet flow log access | `string` | `"corelight-vnet-flow-identity"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources created by this module | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_identity_client_id"></a> [identity\_client\_id](#output\_identity\_client\_id) | Client ID of the managed identity (for Workload Identity or AZURE\_CLIENT\_ID) |
| <a name="output_identity_id"></a> [identity\_id](#output\_identity\_id) | Resource ID of the user-assigned managed identity (for attaching to VMSS) |
| <a name="output_identity_principal_id"></a> [identity\_principal\_id](#output\_identity\_principal\_id) | Principal ID of the managed identity |
<!-- END_TF_DOCS -->
