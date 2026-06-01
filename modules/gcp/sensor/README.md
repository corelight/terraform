# GCP Sensor

Auto-scaling Corelight sensor deployment on GCP via a Managed Instance Group with internal load balancer and Packet Mirroring.

## Usage

```hcl
module "sensor" {
  source = "github.com/corelight/terraform//modules/gcp/sensor?ref=v28.4.0-1"

  project_id             = "project-12345"
  region                 = "us-central1"
  network_mgmt_name      = "mgmt-vpc"
  subnetwork_mgmt_name   = "mgmt-subnet"
  network_prod_name      = "prod-vpc"
  subnetwork_mon_name    = "monitor-subnet"
  subnetwork_mon_cidr    = "10.0.1.0/24"
  subnetwork_mon_gateway = "10.0.1.1"
  instance_ssh_key_pub   = file("~/.ssh/id_rsa.pub")
  image                  = "projects/your-project/global/images/corelight-sensor"
  community_string       = "your-community-string"

  fleet_token          = "your-fleet-token"
  fleet_url            = "https://fleet.example.com:1443/..."
  fleet_server_sslname = "fleet.example.com"
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
| <a name="input_community_string"></a> [community\_string](#input\_community\_string) | the community string (api string) often times referenced by Fleet | `string` | n/a | yes |
| <a name="input_fleet_server_sslname"></a> [fleet\_server\_sslname](#input\_fleet\_server\_sslname) | The SSL hostname for the fleet server | `string` | n/a | yes |
| <a name="input_fleet_token"></a> [fleet\_token](#input\_fleet\_token) | The pairing token from the Fleet UI. Must be set if 'fleet\_url' is provided | `string` | n/a | yes |
| <a name="input_fleet_url"></a> [fleet\_url](#input\_fleet\_url) | The URL of the fleet instance from the Fleet UI. Must be set if 'fleet\_token' is provided | `string` | n/a | yes |
| <a name="input_image"></a> [image](#input\_image) | the image from which to initialize this disk | `string` | n/a | yes |
| <a name="input_instance_ssh_key_pub"></a> [instance\_ssh\_key\_pub](#input\_instance\_ssh\_key\_pub) | path to the SSH pub key for the instances(s) | `string` | n/a | yes |
| <a name="input_network_mgmt_name"></a> [network\_mgmt\_name](#input\_network\_mgmt\_name) | the name or self\_link of the mgmt network to attach this interface to | `string` | n/a | yes |
| <a name="input_network_prod_name"></a> [network\_prod\_name](#input\_network\_prod\_name) | the name or self\_link of the prod network to attach this interface to | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project to deploy Corelight sensor resources | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | the GCP region | `string` | n/a | yes |
| <a name="input_subnetwork_mgmt_name"></a> [subnetwork\_mgmt\_name](#input\_subnetwork\_mgmt\_name) | the name or self\_link of the mgmt subnetwork to attach this interface to | `string` | n/a | yes |
| <a name="input_subnetwork_mon_cidr"></a> [subnetwork\_mon\_cidr](#input\_subnetwork\_mon\_cidr) | the monitor subnet for the sensor(s) | `string` | n/a | yes |
| <a name="input_subnetwork_mon_gateway"></a> [subnetwork\_mon\_gateway](#input\_subnetwork\_mon\_gateway) | the monitor subnet's gateway address | `string` | n/a | yes |
| <a name="input_subnetwork_mon_name"></a> [subnetwork\_mon\_name](#input\_subnetwork\_mon\_name) | the name or self\_link of the monitor subnetwork to attach this interface to | `string` | n/a | yes |
| <a name="input_firewall_resource_name"></a> [firewall\_resource\_name](#input\_firewall\_resource\_name) | the name of the firewall resource | `string` | `"corelight-sensor-health-check-rule"` | no |
| <a name="input_fleet_http_proxy"></a> [fleet\_http\_proxy](#input\_fleet\_http\_proxy) | (optional) the proxy URL for HTTP traffic from the fleet | `string` | `""` | no |
| <a name="input_fleet_https_proxy"></a> [fleet\_https\_proxy](#input\_fleet\_https\_proxy) | (optional) the proxy URL for HTTPS traffic from the fleet | `string` | `""` | no |
| <a name="input_fleet_no_proxy"></a> [fleet\_no\_proxy](#input\_fleet\_no\_proxy) | (optional) hosts or domains to bypass the proxy for fleet traffic | `string` | `""` | no |
| <a name="input_forwarding_rule_resource_name"></a> [forwarding\_rule\_resource\_name](#input\_forwarding\_rule\_resource\_name) | the name of the forwarding rule resource | `string` | `"corelight-traffic-forwarding-rule"` | no |
| <a name="input_health_check_http_port"></a> [health\_check\_http\_port](#input\_health\_check\_http\_port) | the port number for the HTTP health check request | `string` | `"41080"` | no |
| <a name="input_image_disk_size"></a> [image\_disk\_size](#input\_image\_disk\_size) | the size of the image in gigabytes | `string` | `"500"` | no |
| <a name="input_instance_size"></a> [instance\_size](#input\_instance\_size) | GCP compute machine type for Fleet Manager | `string` | `"e2-standard-8"` | no |
| <a name="input_instance_ssh_user"></a> [instance\_ssh\_user](#input\_instance\_ssh\_user) | the image's default user | `string` | `"ec2-user"` | no |
| <a name="input_instance_template_group_manager_base_instance_name"></a> [instance\_template\_group\_manager\_base\_instance\_name](#input\_instance\_template\_group\_manager\_base\_instance\_name) | the base instance name to use for instances in this group | `string` | `"corelight"` | no |
| <a name="input_instance_template_group_manager_resource_name"></a> [instance\_template\_group\_manager\_resource\_name](#input\_instance\_template\_group\_manager\_resource\_name) | the name of the instance group manager resource | `string` | `"corelight-mig-manager"` | no |
| <a name="input_instance_template_resource_name_prefix"></a> [instance\_template\_resource\_name\_prefix](#input\_instance\_template\_resource\_name\_prefix) | the name prefix of the instance template resource | `string` | `"corelight-mig-template-"` | no |
| <a name="input_license_key"></a> [license\_key](#input\_license\_key) | Your Corelight sensor license key. Optional if fleet\_url is configured. | `string` | `""` | no |
| <a name="input_packet_mirror_network_tag"></a> [packet\_mirror\_network\_tag](#input\_packet\_mirror\_network\_tag) | the packet mirror policy tag for mirrored resources | `string` | `"traffic-source"` | no |
| <a name="input_packet_mirroring_resource_name"></a> [packet\_mirroring\_resource\_name](#input\_packet\_mirroring\_resource\_name) | the name of the packet mirroring resource | `string` | `"corelight-traffic-mirroring"` | no |
| <a name="input_region_autoscaler_policy_cooldown_period"></a> [region\_autoscaler\_policy\_cooldown\_period](#input\_region\_autoscaler\_policy\_cooldown\_period) | the number of seconds that the autoscaler should wait before it starts collecting information from a new instance | `number` | `600` | no |
| <a name="input_region_autoscaler_policy_cpu_utilization_target"></a> [region\_autoscaler\_policy\_cpu\_utilization\_target](#input\_region\_autoscaler\_policy\_cpu\_utilization\_target) | the target CPU utilization that the autoscaler should maintain | `number` | `0.4` | no |
| <a name="input_region_autoscaler_policy_max_replicas"></a> [region\_autoscaler\_policy\_max\_replicas](#input\_region\_autoscaler\_policy\_max\_replicas) | the maximum number of instances that the autoscaler can scale up to | `number` | `3` | no |
| <a name="input_region_autoscaler_policy_min_replicas"></a> [region\_autoscaler\_policy\_min\_replicas](#input\_region\_autoscaler\_policy\_min\_replicas) | ghe minimum number of replicas that the autoscaler can scale down to | `number` | `1` | no |
| <a name="input_region_autoscaler_resource_name"></a> [region\_autoscaler\_resource\_name](#input\_region\_autoscaler\_resource\_name) | the name of the qutoscaler resource | `string` | `"corelight-autoscale"` | no |
| <a name="input_region_backend_service_resource_name"></a> [region\_backend\_service\_resource\_name](#input\_region\_backend\_service\_resource\_name) | the name of the region backend service resource | `string` | `"corelight-traffic-ilb-backend-service"` | no |
| <a name="input_region_health_check_resource_name"></a> [region\_health\_check\_resource\_name](#input\_region\_health\_check\_resource\_name) | the name of the health check resource | `string` | `"corelight-traffic-monitor-health-check"` | no |
| <a name="input_region_probe_source_ranges_cidr"></a> [region\_probe\_source\_ranges\_cidr](#input\_region\_probe\_source\_ranges\_cidr) | the GCP health check probe ranges, see https://cloud.google.com/load-balancing/docs/health-check-concepts#ip-ranges | `list(string)` | <pre>[<br/>  "130.211.0.0/22",<br/>  "35.191.0.0/16"<br/>]</pre> | no |
| <a name="input_sensor_service_account_email"></a> [sensor\_service\_account\_email](#input\_sensor\_service\_account\_email) | The service account email granting the sensor cloud features permission to GCP APIs and services | `string` | `""` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | List of zones within the region to distribute sensors across. If empty, sensors will be distributed across all available zones in the region. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_distribution_zones"></a> [distribution\_zones](#output\_distribution\_zones) | The zones where sensors are distributed |
| <a name="output_firewall_id"></a> [firewall\_id](#output\_firewall\_id) | n/a |
| <a name="output_forwarding_rule_id"></a> [forwarding\_rule\_id](#output\_forwarding\_rule\_id) | n/a |
| <a name="output_instance_template_group_manager_id"></a> [instance\_template\_group\_manager\_id](#output\_instance\_template\_group\_manager\_id) | n/a |
| <a name="output_instance_template_id"></a> [instance\_template\_id](#output\_instance\_template\_id) | n/a |
| <a name="output_packet_mirroring_id"></a> [packet\_mirroring\_id](#output\_packet\_mirroring\_id) | n/a |
| <a name="output_region_autoscaler_id"></a> [region\_autoscaler\_id](#output\_region\_autoscaler\_id) | n/a |
| <a name="output_region_backend_service_id"></a> [region\_backend\_service\_id](#output\_region\_backend\_service\_id) | n/a |
| <a name="output_region_health_check_id"></a> [region\_health\_check\_id](#output\_region\_health\_check\_id) | n/a |
<!-- END_TF_DOCS -->

For deployment guidance, sizing recommendations, troubleshooting, and architecture
details, see the official Corelight documentation.
