variable "subscription_id" {
  description = "The ID (UUID) of the Azure Subscription where resources will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group where resources will be created"
  type        = string
}

variable "location" {
  description = "Azure location where resources will be deployed"
  type        = string
}

####################################################################################################
# Storage Account Configuration
####################################################################################################

variable "auto_create_storage_account" {
  description = "If true, creates a new storage account using the storage submodule. If false, you must provide enrichment_storage_account_name and enrichment_storage_account_resource_group."
  type        = bool
  default     = false
}

variable "enrichment_storage_account_name" {
  description = "The name of the storage account where enrichment data will be stored. Required when auto_create_storage_account is false. When auto_create_storage_account is true, this is the name for the new storage account."
  type        = string
  default     = null
}

variable "enrichment_storage_account_resource_group" {
  description = "The resource group of the storage account where enrichment data will be stored. Required when auto_create_storage_account is false."
  type        = string
  default     = null
}

variable "enrichment_storage_account_container_name" {
  description = "The name of the storage container for enrichment data. Used when auto_create_storage_account is true."
  type        = string
  default     = "enrichment"
}

####################################################################################################
# Service Bus Configuration
####################################################################################################

variable "auto_create_service_bus" {
  description = "If true, creates a new Service Bus namespace and queue using the service_bus submodule. If false, you must provide service_bus_queue_id."
  type        = bool
  default     = false
}

variable "service_bus_queue_id" {
  description = "The resource ID of the Service Bus queue that the identity needs access to. Required when auto_create_service_bus is false."
  type        = string
  default     = null
}

variable "service_bus_namespace_name" {
  description = "The name of the Service Bus namespace. Used when auto_create_service_bus is true."
  type        = string
  default     = "corelight-enrichment-state-change-bus"
}

variable "service_bus_queue_name" {
  description = "The name of the Service Bus queue. Used when auto_create_service_bus is true."
  type        = string
  default     = "corelight-enrichment-state-change-queue"
}

####################################################################################################
# Identity Configuration
####################################################################################################

variable "app_identity_name" {
  description = "The name of the user assigned identity which the Container App will run as"
  type        = string
  default     = "corelight-enrichment-user"
}

variable "enrichment_role_definition_name" {
  description = "The name of the custom Corelight enrichment role definition"
  type        = string
  default     = "corelight-enrichment-role"
}

variable "tags" {
  description = "Tags to apply to created resources"
  type        = map(string)
  default     = {}
}
