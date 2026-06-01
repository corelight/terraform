####################################################################################################
# Local Variables
####################################################################################################
locals {
  tags = merge(var.tags, {
    terraform = "true"
    purpose   = "Corelight"
  })
}

####################################################################################################
# Create a resource group for the corelight resources
####################################################################################################
resource "azurerm_resource_group" "sensor_rg" {
  location = var.location
  name     = var.resource_group_name

  tags = local.tags
}

####################################################################################################
# Get data on the existing vnet
####################################################################################################
data "azurerm_virtual_network" "existing_vnet" {
  name                = var.virtual_network_name
  resource_group_name = var.virtual_network_resource_group
}

####################################################################################################
# Create subnets for sensor management and monitoring
####################################################################################################
resource "azurerm_subnet" "management_subnet" {
  name                 = "${var.deployment_name}-management-subnet"
  resource_group_name  = var.virtual_network_resource_group
  virtual_network_name = data.azurerm_virtual_network.existing_vnet.name
  address_prefixes     = [var.management_subnet_cidr]
}

resource "azurerm_subnet" "monitoring_subnet" {
  name                 = "${var.deployment_name}-monitoring-subnet"
  resource_group_name  = var.virtual_network_resource_group
  virtual_network_name = data.azurerm_virtual_network.existing_vnet.name
  address_prefixes     = [var.monitoring_subnet_cidr]
}

####################################################################################################
# Deploy the Sensor
####################################################################################################
module "sensor" {
  source = "../../../modules/azure/sensor"

  license_key               = var.license_key
  location                  = var.location
  resource_group_name       = azurerm_resource_group.sensor_rg.name
  management_subnet_id      = azurerm_subnet.management_subnet.id
  monitoring_subnet_id      = azurerm_subnet.monitoring_subnet.id
  corelight_sensor_image_id = var.corelight_sensor_image_id
  community_string          = var.community_string
  sensor_ssh_public_key     = var.sensor_ssh_public_key

  fleet_token          = var.fleet_token
  fleet_url            = var.fleet_url
  fleet_server_sslname = var.fleet_server_sslname

  # Resource naming with deployment prefix
  scale_set_name                        = "${var.deployment_name}-sensor"
  load_balancer_name                    = "${var.deployment_name}-sensor-lb"
  nat_gateway_name                      = "${var.deployment_name}-nat-gw"
  nat_gateway_ip_name                   = "${var.deployment_name}-nat-gw-ip"
  autoscale_setting_name                = "${var.deployment_name}-autoscale-cfg"
  lb_management_frontend_ip_config_name = "${var.deployment_name}-management"
  lb_monitoring_frontend_ip_config_name = "${var.deployment_name}-monitoring"
  lb_mgmt_backend_address_pool_name     = "${var.deployment_name}-management-pool"
  lb_mon_backend_address_pool_name      = "${var.deployment_name}-monitoring-pool"
  lb_monitoring_probe_name              = "${var.deployment_name}-sensor-health-check"
  lb_management_probe_name              = "${var.deployment_name}-ssh-health-check"
  lb_vxlan_rule_name                    = "${var.deployment_name}-vxlan-lb-rule"
  lb_ssh_rule_name                      = "${var.deployment_name}-ssh-lb-rule"

  # Optional settings
  virtual_machine_size         = var.virtual_machine_size
  virtual_machine_os_disk_size = var.virtual_machine_os_disk_size
  fedramp_mode_enabled         = var.fedramp_mode_enabled
  prometheus_enabled           = var.prometheus_enabled
  azure_fips_enabled           = var.azure_fips_enabled

  tags = local.tags
}

####################################################################################################
# (Optional) Assign the VMSS identity access to the enrichment bucket if enabled
####################################################################################################
resource "azurerm_role_assignment" "enrichment_data_access" {
  count = var.enrichment_storage_account_id != "" ? 1 : 0

  principal_id         = module.sensor.sensor_identity_principal_id
  scope                = var.enrichment_storage_account_id
  role_definition_name = "Storage Blob Data Reader"
}

