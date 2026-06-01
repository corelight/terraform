variable "subscription_id" {
  description = "The ID (UUID) of the Azure Subscription where resources will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group where resources will be deployed"
  type        = string
}

variable "location" {
  description = "Azure location where resources will be deployed"
  type        = string
}

variable "auto_create_enrichment_storage_account" {
  description = "If true, the module will create a storage account and container for enrichment data. If false, you must provide enrichment_storage_account_id and enrichment_storage_account_container."
  type        = bool
  default     = false
}

variable "enrichment_storage_account_id" {
  description = "The resource ID of the storage account where enrichment data will be centralized. Required when auto_create_enrichment_storage_account is false."
  type        = string
  default     = null
}

variable "enrichment_storage_account_container" {
  description = "The storage account container that will store the cloud resource data. Required when auto_create_enrichment_storage_account is false."
  type        = string
  default     = null
}

variable "enrichment_storage_account_name" {
  description = "The name of the storage account to create when auto_create_enrichment_storage_account is true. Must be globally unique, 3-24 characters, lowercase letters and numbers only."
  type        = string
  default     = null
}

variable "enrichment_storage_account_container_name" {
  description = "The name of the storage container to create when auto_create_enrichment_storage_account is true."
  type        = string
  default     = "enrichment"
}

variable "event_grid_system_topic_name" {
  description = "The name of the event grid system topic"
  type        = string
}

variable "event_grid_system_topic_resource_group" {
  description = "The resource group of the event grid system topic"
  type        = string
}

variable "auto_create_iam" {
  description = "If true, the module will create the managed identity and role assignments. If false, you must provide app_identity_id and app_identity_client_id."
  type        = bool
  default     = false
}

variable "app_identity_id" {
  description = "The resource ID of the user assigned identity for the Container App. Required when auto_create_iam is false."
  type        = string
  default     = null
}

variable "app_identity_client_id" {
  description = "The client ID of the user assigned identity for the Container App. Required when auto_create_iam is false."
  type        = string
  default     = null
}

variable "app_identity_name" {
  description = "The name of the user assigned identity to create when auto_create_iam is true."
  type        = string
  default     = "corelight-enrichment-user"
}

variable "enrichment_role_definition_name" {
  description = "The name of the custom role definition to create when auto_create_iam is true."
  type        = string
  default     = "corelight-enrichment-role"
}

## Variables with defaults
variable "image_name" {
  description = "The name of the Corelight Azure enrichment application"
  type        = string
  default     = "corelight/sensor-enrichment-azure"
}

variable "image_tag" {
  description = "The tag for the Corelight Azure enrichment application"
  type        = string
  default     = "latest"
}

variable "app_container_name" {
  description = "The name of the running enrichment container"
  type        = string
  default     = "corelightcloudenrichment"
}

variable "app_container_cpu" {
  description = "The CPU allocated for the container"
  type        = number
  default     = 0.25
}
variable "app_container_memory" {
  description = "The memory allocated for the container"
  type        = string
  default     = "0.5Gi"
}

variable "event_grid_subscription_name" {
  description = "The name of the EventGrid subscription on the System Topic"
  type        = string
  default     = "corelight-system-topic-sub"
}

####################################################################################################
# Service Bus Configuration
####################################################################################################

variable "auto_create_service_bus" {
  description = "If true, the module will create a Service Bus namespace and queue. If false, you must provide service_bus_queue_id and service_bus_namespace_fqdn."
  type        = bool
  default     = true
}

variable "service_bus_queue_id" {
  description = "The resource ID of an existing Service Bus queue. Required when auto_create_service_bus is false."
  type        = string
  default     = null
}

variable "service_bus_namespace_fqdn" {
  description = "The FQDN of an existing Service Bus namespace (e.g., 'mybus.servicebus.windows.net'). Required when auto_create_service_bus is false."
  type        = string
  default     = null
}

variable "service_bus_queue_name" {
  description = "The Service Bus queue name. Used when auto_create_service_bus is true, or to identify the queue name when auto_create_service_bus is false."
  type        = string
  default     = "corelight-enrichment-state-change-queue"
}

variable "service_bus_name" {
  description = "The name of the Service Bus namespace to create when auto_create_service_bus is true."
  type        = string
  default     = "corelight-enrichment-state-change-bus"
}

variable "app_name" {
  description = "The name of the enrichment Container App"
  type        = string
  default     = "corelight-cloud-enrichment"
}

variable "app_sku" {
  description = "The enrichment Container App SKU"
  type        = string
  default     = "PerGB2018"
}

variable "app_env_locations" {
  description = "The Azure locations the Container App should collect cloud resource data"
  type        = list(string)
  default = [
    "eastus",
    "eastus2",
    "southcentralus",
    "westus2",
    "westus3",
    "australiaeast",
    "southeastasia",
    "northeurope",
    "swedencentral",
    "uksouth",
    "westeurope",
    "centralus",
    "southafricanorth",
    "centralindia",
    "eastasia",
    "japaneast",
    "koreacentral",
    "canadacentral",
    "francecentral",
    "germanywestcentral",
    "italynorth",
    "norwayeast",
    "polandcentral",
    "switzerlandnorth",
    "uaenorth",
    "brazilsouth",
    "centraluseuap",
    "israelcentral",
    "qatarcentral",
  ]
}

variable "app_env_object_prefix" {
  description = "The prefix prepended to all objects written to the Azure storage account container"
  type        = string
  default     = "corelight"
}

variable "app_env_log_level" {
  description = "The log level the Container App should run. Set to \"debug\" while troubleshooting for additional context and logs"
  type        = string
  default     = "info"
}

variable "app_environment_name" {
  description = "The name of the Container App Environment used by the Container App"
  type        = string
  default     = "corelight-app-env"
}

variable "app_log_retention" {
  description = "How long the Container App should retain logs"
  type        = number
  default     = 30
}

variable "tags" {
  description = "(optional) Any tags that should be applied to resources deployed by the module"
  type        = map(string)
  default     = {}
}
