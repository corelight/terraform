# GCP Enrichment

Cloud enrichment service for Corelight sensors on GCP (Cloud Run + Pub/Sub + Cloud Scheduler).

## Usage

```hcl
module "enrichment_org_iam" {
  source = "github.com/corelight/terraform//modules/gcp/enrichment/submodules/org-iam?ref=v28.4.0-1"

  organization_id    = "987654321"
  custom_org_role_id = "corelight_enrichment_role"
}

module "enrichment" {
  source = "github.com/corelight/terraform//modules/gcp/enrichment?ref=v28.4.0-1"

  project_id             = "project-12345"
  location               = "us-central1"
  folder_id              = "123456789"
  enrichment_bucket_name = "enrichment-data-54321"
  service_account_id     = "enrichment-service-account"
  organization_role_id   = module.enrichment_org_iam.custom_org_role_id
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3.2 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >=6.38.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | >=6.38.0 |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_enrichment_bucket_name"></a> [enrichment\_bucket\_name](#input\_enrichment\_bucket\_name) | The GCS bucket where cloud enrichment data will be centrally stored | `string` | n/a | yes |
| <a name="input_folder_id"></a> [folder\_id](#input\_folder\_id) | GCP folder to watch for cloud resource state change events | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | GCP location to deploy Corelight enrichment resources | `string` | n/a | yes |
| <a name="input_organization_role_id"></a> [organization\_role\_id](#input\_organization\_role\_id) | The organization role id granting access to enumerate folders and projects | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project to deploy Corelight enrichment resources | `string` | n/a | yes |
| <a name="input_service_account_id"></a> [service\_account\_id](#input\_service\_account\_id) | ID of the service account used for enrichment | `string` | n/a | yes |
| <a name="input_cloud_asset_folder_feed_id"></a> [cloud\_asset\_folder\_feed\_id](#input\_cloud\_asset\_folder\_feed\_id) | The name of the Asset Folder Feed which will inform the Cloud Run service when cloud resources have changed state | `string` | `"corelight-cloud-enrichment-folder-feed"` | no |
| <a name="input_cloud_run_bucket_object_prefix"></a> [cloud\_run\_bucket\_object\_prefix](#input\_cloud\_run\_bucket\_object\_prefix) | The prefix prepended to every bucket object. Useful when storing data in a shared bucket.<br/>    Must be in sync with the Corelight Cloud Enrichment configuration. | `string` | `"corelight"` | no |
| <a name="input_cloud_run_image"></a> [cloud\_run\_image](#input\_cloud\_run\_image) | The Corelight application image which gathers and stores cloud resource data in GCS | `string` | `"corelight/sensor-enrichment-gcp"` | no |
| <a name="input_cloud_run_image_tag"></a> [cloud\_run\_image\_tag](#input\_cloud\_run\_image\_tag) | The version of the Corelight application to deploy | `string` | `"latest"` | no |
| <a name="input_cloud_run_locations"></a> [cloud\_run\_locations](#input\_cloud\_run\_locations) | The list of locations the Cloud Run service will look for applicable cloud resources | `list(string)` | <pre>[<br/>  "asia-east1",<br/>  "asia-east2",<br/>  "asia-northeast1",<br/>  "asia-northeast2",<br/>  "asia-northeast3",<br/>  "asia-south1",<br/>  "asia-south2",<br/>  "asia-southeast1",<br/>  "asia-southeast2",<br/>  "australia-southeast1",<br/>  "australia-southeast2",<br/>  "europe-central2",<br/>  "europe-north1",<br/>  "europe-southwest1",<br/>  "europe-west1",<br/>  "europe-west2",<br/>  "europe-west3",<br/>  "europe-west4",<br/>  "europe-west6",<br/>  "europe-west8",<br/>  "europe-west9",<br/>  "europe-west10",<br/>  "europe-west12",<br/>  "me-central1",<br/>  "me-central2",<br/>  "me-west1",<br/>  "northamerica-northeast1",<br/>  "northamerica-northeast2",<br/>  "southamerica-east1",<br/>  "southamerica-west1",<br/>  "us-central1",<br/>  "us-east1",<br/>  "us-east4",<br/>  "us-east5",<br/>  "us-south1",<br/>  "us-west1",<br/>  "us-west2",<br/>  "us-west3",<br/>  "us-west4"<br/>]</pre> | no |
| <a name="input_cloud_run_log_level"></a> [cloud\_run\_log\_level](#input\_cloud\_run\_log\_level) | The log level the cloud run service runs with. Set to "debug" if troubleshooting | `string` | `"info"` | no |
| <a name="input_cloud_run_service_name"></a> [cloud\_run\_service\_name](#input\_cloud\_run\_service\_name) | The name of the Cloud Run service deployed to collect cloud resource data | `string` | `"corelight-cloud-enrichment"` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | (optional) Any Labels you wish to add to all resources deployed by this module | `object({})` | `{}` | no |
| <a name="input_message_retention_duration"></a> [message\_retention\_duration](#input\_message\_retention\_duration) | How long the PubSub topic will retain cloud resource state change messages | `string` | `"86400s"` | no |
| <a name="input_project_role_id"></a> [project\_role\_id](#input\_project\_role\_id) | The ID of the role granting access to GCS | `string` | `"corelight_cloud_enrichment"` | no |
| <a name="input_project_role_title"></a> [project\_role\_title](#input\_project\_role\_title) | The title of the role granting the Cloud Run Service Account access to cloud resources | `string` | `"Corelight Cloud Enrichment Role"` | no |
| <a name="input_pubsub_subscription_name"></a> [pubsub\_subscription\_name](#input\_pubsub\_subscription\_name) | The name of the PubSub subscription the Cloud Run service will use to keep cloud resource data up-to-date | `string` | `"corelight-cloud-enrichment-sub"` | no |
| <a name="input_scheduler_attempt_deadline"></a> [scheduler\_attempt\_deadline](#input\_scheduler\_attempt\_deadline) | The timeout for the cloud scheduler job to get a response from the Cloud Run service | `string` | `"60s"` | no |
| <a name="input_scheduler_job_cron"></a> [scheduler\_job\_cron](#input\_scheduler\_job\_cron) | The cron expression used by the cloud scheduler job | `string` | `"*/15 * * * *"` | no |
| <a name="input_scheduler_job_name"></a> [scheduler\_job\_name](#input\_scheduler\_job\_name) | the name of the cloud scheduler job which initiates collection of all pertinent cloud resources | `string` | `"corelight-cloud-enrichment-scheduled"` | no |
| <a name="input_scheduler_job_time_zone"></a> [scheduler\_job\_time\_zone](#input\_scheduler\_job\_time\_zone) | The time zone the cloud scheduled will run using | `string` | `"America/Chicago"` | no |
| <a name="input_service_account_display_name"></a> [service\_account\_display\_name](#input\_service\_account\_display\_name) | The display name for the service account used by Corelight Enrichment | `string` | `"Corelight Enrichment"` | no |
| <a name="input_topic_name"></a> [topic\_name](#input\_topic\_name) | The name of the PubSub topic fed by the Asset Folder Feed | `string` | `"corelight-cloud-enrichment"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cloud_run_service_name"></a> [cloud\_run\_service\_name](#output\_cloud\_run\_service\_name) | n/a |
| <a name="output_cloud_scheduler_job_id"></a> [cloud\_scheduler\_job\_id](#output\_cloud\_scheduler\_job\_id) | n/a |
| <a name="output_enabled_services"></a> [enabled\_services](#output\_enabled\_services) | n/a |
| <a name="output_project_iam_role_id"></a> [project\_iam\_role\_id](#output\_project\_iam\_role\_id) | n/a |
| <a name="output_project_service_account_id"></a> [project\_service\_account\_id](#output\_project\_service\_account\_id) | n/a |
| <a name="output_pubsub_subscription_name"></a> [pubsub\_subscription\_name](#output\_pubsub\_subscription\_name) | n/a |
| <a name="output_pubsub_topic_name"></a> [pubsub\_topic\_name](#output\_pubsub\_topic\_name) | n/a |
<!-- END_TF_DOCS -->

For deployment guidance, sizing recommendations, troubleshooting, and architecture
details, see the official Corelight documentation.
