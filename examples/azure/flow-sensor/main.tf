module "vnet_flow_access" {
  source = "../../../modules/azure/sensor-single/submodules/vnet_flow_storage_access"

  resource_group_name = var.resource_group_name
  location            = var.location
  storage_account_id  = var.storage_account_id
  identity_name       = "${var.deployment_name}-vnet-flow-identity"

  tags = var.tags
}

module "sensor" {
  source = "../../../modules/azure/sensor-single"

  deployment_name           = var.deployment_name
  location                  = var.location
  resource_group_name       = var.resource_group_name
  corelight_sensor_image_id = var.corelight_sensor_image_id
  sensor_ssh_public_key     = var.sensor_ssh_public_key
  community_string          = var.community_string

  management_subnet_id = var.management_subnet_id
  monitoring_subnet_id = var.monitoring_subnet_id

  management_interface_public_ip = var.management_interface_public_ip
  ssh_allow_cidrs                = var.ssh_allow_cidrs

  license_key          = var.license_key
  fleet_token          = var.fleet_token
  fleet_url            = var.fleet_url
  fleet_server_sslname = var.fleet_server_sslname

  user_assigned_identity_ids = [module.vnet_flow_access.identity_id]

  tags = var.tags
}
