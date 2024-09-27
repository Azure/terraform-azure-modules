resource "azurerm_virtual_network" "vnet" {
  address_space       = ["192.168.0.0/16"]
  location            = azurerm_resource_group.state_rg.location
  name                = "control-plane-meta-controller"
  resource_group_name = azurerm_resource_group.state_rg.name
}

resource "azurerm_subnet" "runner" {
  address_prefixes     = ["192.168.128.0/24"]
  name                 = "private"
  resource_group_name  = azurerm_resource_group.state_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  service_endpoints    = ["Microsoft.Storage"]
}

resource "azurerm_subnet" "bambrane_onees_pool" {
  address_prefixes     = ["192.168.100.0/24"]
  name                 = "runner"
  resource_group_name  = azurerm_resource_group.state_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  delegation {
    name = "delegation"

    service_delegation {
      name = "Microsoft.CloudTest/hostedpools"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

locals {
  endpoints = toset(["blob"])
}

#resource "azurerm_private_dns_zone" "private_links" {
#  name                = "privatelink.blob.core.windows.net"
#  resource_group_name = azurerm_resource_group.state_rg.name
#}
#
#resource "azurerm_private_dns_zone" "public_endpoints" {
#  name                = "blob.core.windows.net"
#  resource_group_name = azurerm_resource_group.state_rg.name
#}
#
#resource "azurerm_private_dns_zone_virtual_network_link" "private_links" {
#  name                  = "blob_${azurerm_virtual_network.vnet.name}_private"
#  private_dns_zone_name = azurerm_private_dns_zone.private_links.name
#  resource_group_name   = azurerm_resource_group.state_rg.name
#  virtual_network_id    = azurerm_virtual_network.vnet.id
#}
#
#resource "azurerm_private_dns_zone_virtual_network_link" "public_endpoints" {
#  name                  = "blob_${azurerm_virtual_network.vnet.name}_public"
#  private_dns_zone_name = azurerm_private_dns_zone.public_endpoints.name
#  resource_group_name   = azurerm_resource_group.state_rg.name
#  virtual_network_id    = azurerm_virtual_network.vnet.id
#}
#
#resource "azurerm_private_endpoint" "blob" {
#  name                = "pe_blob"
#  location            = azurerm_resource_group.state_rg.location
#  resource_group_name = azurerm_resource_group.state_rg.name
#  subnet_id           = azurerm_subnet.runner.id
#
#  private_service_connection {
#    name                           = "blob"
#    private_connection_resource_id = azurerm_storage_account.state.id
#    subresource_names              = ["blob"]
#    is_manual_connection           = false
#  }
#}
#
#resource "azurerm_private_endpoint" "provision_script_blob" {
#  name                = "ps_blob"
#  location            = azurerm_resource_group.state_rg.location
#  resource_group_name = azurerm_resource_group.state_rg.name
#  subnet_id           = azurerm_subnet.runner.id
#
#  private_service_connection {
#    name                           = "blob"
#    private_connection_resource_id = azurerm_storage_account.bambrane_provision_script.id
#    subresource_names              = ["blob"]
#    is_manual_connection           = false
#  }
#}
#
#resource "azurerm_private_dns_a_record" "private" {
#  name                = azurerm_storage_account.state.name
#  records             = [azurerm_private_endpoint.blob.private_service_connection[0].private_ip_address]
#  resource_group_name = azurerm_resource_group.state_rg.name
#  ttl                 = 600
#  zone_name           = azurerm_private_dns_zone.private_links.name
#}
#
#resource "azurerm_private_dns_cname_record" "public" {
#  name                = azurerm_storage_account.state.name
#  record              = azurerm_private_dns_a_record.private.fqdn
#  resource_group_name = azurerm_private_dns_a_record.private.resource_group_name
#  ttl                 = 600
#  zone_name           = azurerm_private_dns_zone.public_endpoints.name
#}
#
#resource "azurerm_private_dns_a_record" "private_provision_script" {
#  name                = azurerm_storage_account.bambrane_provision_script.name
#  records             = [azurerm_private_endpoint.provision_script_blob.private_service_connection[0].private_ip_address]
#  resource_group_name = azurerm_resource_group.state_rg.name
#  ttl                 = 600
#  zone_name           = azurerm_private_dns_zone.private_links.name
#}
#
#resource "azurerm_private_dns_cname_record" "public_provision_script" {
#  name                = azurerm_storage_account.bambrane_provision_script.name
#  record              = azurerm_private_dns_a_record.private_provision_script.fqdn
#  resource_group_name = azurerm_private_dns_a_record.private.resource_group_name
#  ttl                 = 600
#  zone_name           = azurerm_private_dns_zone.public_endpoints.name
#}