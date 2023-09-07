#resource "azurerm_virtual_network" "onees_vnet" {
#  address_space       = ["192.168.0.0/16"]
#  location            = azurerm_resource_group.onees_runner_pool.location
#  name                = "runner_vnet"
#  resource_group_name = azurerm_resource_group.onees_runner_pool.name
#}
#
#resource "azurerm_subnet" "fw" {
#  address_prefixes     = ["192.168.0.0/24"]
#  name                 = "AzureFirewallSubnet"
#  resource_group_name  = azurerm_resource_group.onees_runner_pool.name
#  virtual_network_name = azurerm_virtual_network.onees_vnet.name
#}
#
#resource "azurerm_subnet" "runner" {
#  address_prefixes     = ["192.168.1.0/24"]
#  name                 = "runner"
#  resource_group_name  = azurerm_resource_group.onees_runner_pool.name
#  virtual_network_name = azurerm_virtual_network.onees_vnet.name
#
#  delegation {
#    name = "delegation"
#
#    service_delegation {
#      name    = "Microsoft.CloudTest/hostedpools"
#      actions = [
#        "Microsoft.Network/virtualNetworks/subnets/join/action",
#      ]
#    }
#  }
#}
#
#resource "azurerm_role_assignment" "onees_subnet_reader" {
#  principal_id         = data.azuread_service_principal.onees_resource_management.object_id
#  scope                = azurerm_subnet.runner.id
#  role_definition_name = "Reader"
#}
#
#resource "azurerm_route_table" "runner" {
#  location                      = azurerm_resource_group.onees_runner_pool.location
#  name                          = "runner_rt"
#  resource_group_name           = azurerm_resource_group.onees_runner_pool.name
#  disable_bgp_route_propagation = false
#}
#
#resource "azurerm_subnet_route_table_association" "runner" {
#  route_table_id = azurerm_route_table.runner.id
#  subnet_id      = azurerm_subnet.runner.id
#}
#
#resource "azurerm_route" "runner_public_network" {
#  address_prefix         = "0.0.0.0/0"
#  name                   = "runner_public_network"
#  next_hop_type          = "VirtualAppliance"
#  resource_group_name    = azurerm_resource_group.onees_runner_pool.name
#  route_table_name       = azurerm_route_table.runner.name
#  next_hop_in_ip_address = azurerm_firewall.onees.ip_configuration[0].private_ip_address
#}
#
#resource "azurerm_route" "runner_no_intranet" {
#  address_prefix      = azurerm_virtual_network.onees_vnet.address_space[0]
#  name                = "no_intranet"
#  next_hop_type       = "None"
#  resource_group_name = azurerm_resource_group.onees_runner_pool.name
#  route_table_name    = azurerm_route_table.runner.name
#}
#
#resource "azurerm_public_ip" "fw" {
#  allocation_method   = "Static"
#  location            = azurerm_resource_group.onees_runner_pool.location
#  name                = "fwpip"
#  resource_group_name = azurerm_resource_group.onees_runner_pool.name
#  sku                 = "Standard"
#}
#
#resource "azurerm_firewall" "onees" {
#  location            = azurerm_resource_group.onees_runner_pool.location
#  name                = "onees_fw"
#  resource_group_name = azurerm_resource_group.onees_runner_pool.name
#  sku_name            = "AZFW_VNet"
#  sku_tier            = "Standard"
#
#  ip_configuration {
#    name                 = "configuration"
#    public_ip_address_id = azurerm_public_ip.fw.id
#    subnet_id            = azurerm_subnet.fw.id
#  }
#}
#
#resource "azurerm_firewall_application_rule_collection" "runner_rule" {
#  action              = "Allow"
#  azure_firewall_name = azurerm_firewall.onees.name
#  name                = "runner_rules"
#  priority            = 100
#  resource_group_name = azurerm_resource_group.onees_runner_pool.name
#
#  dynamic "rule" {
#    for_each = local.runner_network_whitelist
#    content {
#      name             = rule.value
#      source_addresses = azurerm_virtual_network.onees_vnet.address_space
#      target_fqdns     = [
#        rule.value
#      ]
#
#      protocol {
#        port = 80
#        type = "Http"
#      }
#      protocol {
#        port = "443"
#        type = "Https"
#      }
#    }
#  }
#}