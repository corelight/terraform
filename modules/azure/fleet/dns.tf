data "azurerm_dns_zone" "selected" {
  count               = var.dns_zone_name != null ? 1 : 0
  name                = var.dns_zone_name
  resource_group_name = var.dns_zone_resource_group_name
}

resource "azurerm_dns_a_record" "fleet" {
  count               = var.dns_zone_name != null ? 1 : 0
  name                = var.subdomain
  zone_name           = data.azurerm_dns_zone.selected[0].name
  resource_group_name = var.dns_zone_resource_group_name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.fleet.id
  tags                = var.tags
}
