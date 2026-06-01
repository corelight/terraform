# GCP Enrichment Organization IAM Submodule

This submodule creates a custom organization-level IAM role required by the Corelight Cloud Enrichment service to enumerate folders, projects, and compute instances across your GCP organization.

## Purpose

The GCP enrichment service needs organization-level permissions to:
- List and get folders within the organization hierarchy
- List and get projects within folders
- List compute instances across projects

This submodule creates a custom IAM role at the organization level with the minimal permissions required for enrichment functionality.

## Usage

This submodule is typically deployed separately from the main enrichment module, as it requires organization-level permissions which are often managed by a different team or process.

### Basic Example

```terraform
module "enrichment_org_iam" {
  source = "github.com/corelight/terraform//modules/gcp/enrichment/submodules/org-iam?ref=v28.4.0-1"

  organization_id    = "123456789012"
  custom_org_role_id = "corelight_enrichment_role"
}

# Pass the output to the main enrichment module
module "enrichment" {
  source = "github.com/corelight/terraform//modules/gcp/enrichment?ref=v28.4.0-1"

  # ... other variables ...
  organization_role_id = module.enrichment_org_iam.custom_org_role_id
}
```

### Custom Role Title

```terraform
module "enrichment_org_iam" {
  source = "github.com/corelight/terraform//modules/gcp/enrichment/submodules/org-iam?ref=v28.4.0-1"

  organization_id       = "123456789012"
  custom_org_role_id    = "corelight_enrichment_role"
  custom_org_role_title = "Custom Enrichment Folder Access"
}
```

## Permissions Granted

The custom role grants the following permissions:
- `resourcemanager.folders.list` - List folders in the organization
- `resourcemanager.folders.get` - Get folder details
- `resourcemanager.projects.list` - List projects
- `resourcemanager.projects.get` - Get project details
- `compute.instances.list` - List compute instances

## Notes

- This submodule requires organization-level permissions to create custom IAM roles
- The `custom_org_role_id` must be unique within your organization
- The role created is organization-wide and can be assigned to service accounts in any project
- Deleting this module will remove the custom role; ensure it's not in use before destroying

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3.2 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >=5.21.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | >=5.21.0 |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_custom_org_role_id"></a> [custom\_org\_role\_id](#input\_custom\_org\_role\_id) | ID of the custom role for folder enumeration | `string` | n/a | yes |
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | Organization the role will be deployed | `string` | n/a | yes |
| <a name="input_custom_org_role_title"></a> [custom\_org\_role\_title](#input\_custom\_org\_role\_title) | Title of the custom role for folder enumeration | `string` | `"Corelight Cloud Enrichment Folder Enumeration"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_custom_org_role_id"></a> [custom\_org\_role\_id](#output\_custom\_org\_role\_id) | n/a |
<!-- END_TF_DOCS -->
