mock_provider "cloudinit" {}

run "preserve_fleet_pairing_with_deployment_metadata" {
  command = plan

  variables {
    sensor_license                       = "test-license-key"
    fleet_community_string               = "test-community"
    sensor_management_interface_name     = "eth1"
    sensor_monitoring_interface_name     = "eth0"
    fleet_token                          = "test-token"
    fleet_url                            = "https://fleet.example.com"
    fleet_server_sslname                 = "fleet.example.com"
    fleet_http_proxy                     = "http://proxy.example.com:8080"
    fleet_https_proxy                    = "http://proxy.example.com:8443"
    fleet_no_proxy                       = "localhost,127.0.0.1"
    deployment_cloud_provider            = "aws"
    deployment_cloud_region              = "us-east-1"
    deployment_traffic_mirroring_enabled = true
    terraform_module_version             = "v29.0.5-7"
    terraform_module                     = "aws/sensor"
  }

  assert {
    condition = try(
      yamldecode(one([
        for file in yamldecode(data.cloudinit_config.config.part[0].content).write_files : file.content
        if file.path == "/etc/corelight/corelightctl.yaml"
        ])).sensor.pairing == {
        token          = "test-token"
        url            = "https://fleet.example.com"
        server_sslname = "fleet.example.com"
        http_proxy     = "http://proxy.example.com:8080"
        https_proxy    = "http://proxy.example.com:8443"
        no_proxy       = "localhost,127.0.0.1"
      },
      false,
    )
    error_message = "Cloud-init must preserve Fleet pairing in corelightctl.yaml when deployment metadata is present"
  }

  assert {
    condition = try(
      yamldecode(base64decode(one([
        for file in yamldecode(data.cloudinit_config.config.part[0].content).write_files : file.content
        if file.path == "/etc/corelight/deployment-metadata.yaml" && try(file.encoding, "") == "b64"
        ]))) == {
        "deployment_metadata.cloud_provider"                  = "aws"
        "deployment_metadata.cloud_region"                    = "us-east-1"
        "deployment_metadata.cloud_traffic_mirroring_enabled" = "true"
        "deployment_metadata.terraform_module_version"        = "v29.0.5-7"
        "deployment_metadata.terraform_module"                = "aws/sensor"
      },
      false,
    )
    error_message = "Cloud-init must keep deployment metadata in a separate decodable file when Fleet pairing is present"
  }
}
