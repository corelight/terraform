# Validate both untagged source and the release-stamped artifact.
mock_provider "cloudinit" {}

run "verify_release_stamped_module_version" {
  command = plan

  variables {
    sensor_license                   = "test-license-key"
    fleet_community_string           = "test-community"
    sensor_management_interface_name = "eth1"
    sensor_monitoring_interface_name = "eth0"
    terraform_module                 = "aws/sensor"
  }

  assert {
    condition = try(
      yamldecode(base64decode(one([
        for file in yamldecode(data.cloudinit_config.config.part[0].content).write_files : file.content
        if file.path == "/etc/corelight/deployment-metadata.yaml" && try(file.encoding, "") == "b64"
        ]))) == merge(
        { "deployment_metadata.terraform_module" = "aws/sensor" },
        chomp(file("${path.module}/../../../../RELEASE_VERSION")) == "" ? {} : {
          "deployment_metadata.terraform_module_version" = chomp(file("${path.module}/../../../../RELEASE_VERSION"))
        },
      ),
      false,
    )
    error_message = "Emitted metadata must use the publish-time version when stamped and omit it in untagged source"
  }
}
