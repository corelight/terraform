mock_provider "cloudinit" {}

run "pair_after_deployment_metadata" {
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
    deployment_traffic_mirroring_enabled = true
    terraform_module_version             = "v29.0.5-7"
    terraform_module                     = "aws/sensor"
  }

  assert {
    condition = try(
      !contains(keys(yamldecode(one([
        for file in yamldecode(data.cloudinit_config.config.part[0].content).write_files : file.content
        if file.path == "/etc/corelight/corelightctl.yaml"
      ])).sensor), "pairing"),
      false,
    )
    error_message = "Pairing must not be in corelightctl.yaml while deployment metadata is applied: a Fleet-managed sensor rejects direct configuration"
  }

  assert {
    condition = try(
      one([
        for file in yamldecode(data.cloudinit_config.config.part[0].content).write_files : file.permissions
        if file.path == "/etc/corelight/fleet-pairing.yaml"
        ]) == "0600" && yamldecode(one([
          for file in yamldecode(data.cloudinit_config.config.part[0].content).write_files : file.content
          if file.path == "/etc/corelight/fleet-pairing.yaml"
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
    error_message = "Cloud-init must stage the complete Fleet pairing in a 0600 drop-in when deployment metadata is present"
  }

  assert {
    condition = strcontains(
      data.cloudinit_config.config.part[0].content,
      "    if ! corelightctl sensor deploy -v; then\n      exit 1\n    fi\n    if ! corelightctl sensor configuration put --file /etc/corelight/deployment-metadata.yaml; then\n      logger -t corelight-deployment-metadata \"Sensor API did not accept deployment metadata; inventory fields will remain null\"\n    fi\n    install -D -m 0600 /etc/corelight/fleet-pairing.yaml /etc/corelight/corelightctl.yaml.d/01-fleet.yaml\n    rm -f /etc/corelight/fleet-pairing.yaml\n    if ! corelightctl sensor deploy -v; then\n      exit 1\n    fi",
    )
    error_message = "Cloud-init must deploy, apply metadata, then install the pairing drop-in and deploy again"
  }

  assert {
    condition = try(
      yamldecode(base64decode(one([
        for file in yamldecode(data.cloudinit_config.config.part[0].content).write_files : file.content
        if file.path == "/etc/corelight/deployment-metadata.yaml" && try(file.encoding, "") == "b64"
        ]))) == {
        "deployment_metadata.cloud_traffic_mirroring_enabled" = "true"
        "deployment_metadata.terraform_module_version"        = "v29.0.5-7"
        "deployment_metadata.terraform_module"                = "aws/sensor"
      },
      false,
    )
    error_message = "Cloud-init must keep deployment metadata in a separate decodable file when Fleet pairing is present"
  }
}

run "keep_inline_pairing_without_deployment_metadata" {
  command = plan

  variables {
    sensor_license                   = "test-license-key"
    fleet_community_string           = "test-community"
    sensor_management_interface_name = "eth1"
    sensor_monitoring_interface_name = "eth0"
    fleet_token                      = "test-token"
    fleet_url                        = "https://fleet.example.com"
    fleet_server_sslname             = "fleet.example.com"
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
      },
      false,
    )
    error_message = "Without deployment metadata, pairing should stay in corelightctl.yaml"
  }

  assert {
    condition     = !strcontains(data.cloudinit_config.config.part[0].content, "fleet-pairing.yaml")
    error_message = "Without deployment metadata, no pairing drop-in should be staged"
  }
}
