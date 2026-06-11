variable "resource_group_name" {
  description = "The resource group where the managed identity will be created"
  type        = string
}

variable "location" {
  description = "The Azure region for the managed identity"
  type        = string
}

variable "identity_name" {
  description = "Name of the user-assigned managed identity for VNet flow log access"
  type        = string
  default     = "corelight-vnet-flow-identity"
}

variable "storage_account_id" {
  description = "The resource ID of the storage account containing VNet flow logs"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources created by this module"
  type        = map(string)
  default     = {}
}
