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
| terraform | >= 1.9.0 |
| azurerm | >= 4.0 |

## Providers

| Name | Version |
| ---- | ------- |
| azurerm | >= 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | -------- |
| resource\_group\_name | The resource group where the managed identity will be created | `string` | n/a | yes |
| location | The Azure region for the managed identity | `string` | n/a | yes |
| identity\_name | Name of the user-assigned managed identity for VNet flow log access | `string` | `"corelight-vnet-flow-identity"` | no |
| storage\_account\_id | The resource ID of the storage account containing VNet flow logs | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| identity\_id | Resource ID of the user-assigned managed identity (for attaching to VMSS) |
| identity\_client\_id | Client ID of the managed identity (for Workload Identity or AZURE\_CLIENT\_ID) |
| identity\_principal\_id | Principal ID of the managed identity |
<!-- END_TF_DOCS -->
