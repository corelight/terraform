output "fleet_public_ip" {
  description = "The public IP address of the Fleet load balancer"
  value       = module.fleet.fleet_public_ip
}

output "fleet_fqdn" {
  description = "The fully qualified domain name for Fleet (if DNS is configured)"
  value       = module.fleet.fleet_fqdn
}

output "fleet_vm_id" {
  description = "Resource ID of the Fleet VM"
  value       = module.fleet.fleet_vm_id
}
