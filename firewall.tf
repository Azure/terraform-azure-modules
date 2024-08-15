resource "azurerm_virtual_network" "onees_vnet" {
  for_each            = local.regions
  address_space       = ["192.168.0.0/16", "10.0.0.0/16"]
  location            = each.value
  name                = "runner_vnet${each.value}"
  resource_group_name = azurerm_resource_group.onees_runner_pool.name
}

resource "azurerm_role_assignment" "onees_vnet_reader" {
  for_each             = local.regions
  principal_id         = "9391c2e6-0102-45b1-94fb-c9fd04dea7df" #1ES Resource Management
  scope                = azurerm_virtual_network.onees_vnet[each.key].id
  role_definition_name = "Reader"
}

resource "azurerm_role_assignment" "onees_vnet_network_contributor" {
  for_each             = local.regions
  principal_id         = "9391c2e6-0102-45b1-94fb-c9fd04dea7df" #1ES Resource Management
  scope                = azurerm_virtual_network.onees_vnet[each.key].id
  role_definition_name = "Network Contributor"
}

resource "azurerm_subnet" "fw" {
  for_each             = local.regions
  address_prefixes     = ["192.168.0.0/24"]
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.onees_runner_pool.name
  virtual_network_name = azurerm_virtual_network.onees_vnet[each.key].name
}

resource "azurerm_public_ip" "runner_pip" {
  for_each            = local.regions
  name                = "runner-pip${each.value}"
  location            = each.value
  resource_group_name = azurerm_resource_group.onees_runner_pool.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "natgw" {
  for_each            = local.regions
  name                = "runner-nat${each.value}"
  location            = each.value
  resource_group_name = azurerm_resource_group.onees_runner_pool.name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "example" {
  for_each             = local.regions
  nat_gateway_id       = azurerm_nat_gateway.natgw[each.value].id
  public_ip_address_id = azurerm_public_ip.runner_pip[each.value].id
}

resource "azurerm_subnet" "runner" {
  for_each             = local.repo_index
  address_prefixes     = [cidrsubnet("10.0.0.0/8", 16, tonumber(each.value))]
  name                 = "runner-${reverse(split("/", each.key))[0]}"
  resource_group_name  = azurerm_resource_group.onees_runner_pool.name
  virtual_network_name = azurerm_virtual_network.onees_vnet[try(local.repo_region[each.key], "eastus")].name

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

resource "azurerm_subnet_nat_gateway_association" "asso" {
  for_each       = local.repo_index
  nat_gateway_id = azurerm_nat_gateway.natgw[try(local.repo_region[each.key], "eastus")].id
  subnet_id      = azurerm_subnet.runner[each.key].id
}

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