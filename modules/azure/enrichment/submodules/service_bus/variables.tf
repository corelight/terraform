variable "namespace_name" {
  description = "The name of the Service Bus namespace."
  type        = string
  default     = "corelight-enrichment-state-change-bus"
}

variable "queue_name" {
  description = "The name of the Service Bus queue."
  type        = string
  default     = "corelight-enrichment-state-change-queue"
}

variable "resource_group_name" {
  description = "The name of the resource group where the Service Bus will be created."
  type        = string
}

variable "location" {
  description = "The Azure location where the Service Bus will be created."
  type        = string
}

variable "sku" {
  description = "The SKU of the Service Bus namespace."
  type        = string
  default     = "Standard"
}

variable "minimum_tls_version" {
  description = "The minimum TLS version for the Service Bus namespace."
  type        = string
  default     = "1.2"
}

variable "tags" {
  description = "Tags to apply to the Service Bus resources."
  type        = map(string)
  default     = {}
}

