variable "organization_id" {
  description = "Organization the role will be deployed"
  type        = string
}

variable "custom_org_role_id" {
  description = "ID of the custom role for folder enumeration"
  type        = string
}

variable "custom_org_role_title" {
  description = "Title of the custom role for folder enumeration"
  type        = string
  default     = "Corelight Cloud Enrichment Folder Enumeration"
}