locals {
  terraform_module_version_raw = var.terraform_module_version != null ? var.terraform_module_version : try(
    chomp(file("${path.module}/../../../../RELEASE_VERSION")),
    null,
  )
  terraform_module_version = local.terraform_module_version_raw == null ? null : (
    length(local.terraform_module_version_raw) <= 64 && can(regex(
      "^v(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)-[1-9][0-9]*$",
      local.terraform_module_version_raw,
    )) ? local.terraform_module_version_raw : null
  )
  deployment_metadata = (
    var.deployment_cloud_provider == null || var.deployment_cloud_region == null
    ? null
    : merge(
      {
        "deployment_metadata.cloud_provider" = var.deployment_cloud_provider
        "deployment_metadata.cloud_region"   = trimspace(var.deployment_cloud_region)
      },
      var.deployment_traffic_mirroring_enabled == null ? {} : {
        "deployment_metadata.cloud_traffic_mirroring_enabled" = tostring(var.deployment_traffic_mirroring_enabled)
      },
      local.terraform_module_version == null ? {} : {
        "deployment_metadata.terraform_module_version" = local.terraform_module_version
      },
    )
  )
  deployment_metadata_yaml = local.deployment_metadata == null ? "" : yamlencode(local.deployment_metadata)
}

data "cloudinit_config" "config" {
  gzip          = var.gzip_config
  base64_encode = var.base64_encode_config

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/templates/cloud-init.yaml.tpl", {
      community_string     = var.fleet_community_string
      license              = var.sensor_license
      prometheus_enabled   = var.prometheus_enabled
      fedramp_mode_enabled = var.fedramp_mode_enabled
      mgmt_int             = var.sensor_management_interface_name
      mon_int              = var.sensor_monitoring_interface_name
      health_port          = var.sensor_health_check_http_port
      probe_ranges         = var.sensor_health_check_probe_source_ranges_cidr
      mon_subnet           = var.subnetwork_monitoring_cidr
      mon_gateway          = var.subnetwork_monitoring_gateway
      deployment_metadata  = local.deployment_metadata_yaml == "" ? "" : base64encode(local.deployment_metadata_yaml)

      fleet_token          = var.fleet_token
      fleet_url            = var.fleet_url
      fleet_server_sslname = var.fleet_server_sslname
      fleet_http_proxy     = var.fleet_http_proxy
      fleet_https_proxy    = var.fleet_https_proxy
      fleet_no_proxy       = var.fleet_no_proxy

      azure_fips_enabled = var.azure_fips_enabled
    })
    filename = "sensor-build.yaml"
  }
}
