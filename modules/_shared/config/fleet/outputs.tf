output "cloudinit_config" {
  value     = data.cloudinit_config.config
  sensitive = true
}
