locals {
  locations = var.dry_run ? [] : [
    "eastus",
  ]
}

resource "azurerm_resource_group" "onees_runner_pool" {
  location = "eastus"
  name     = "1esrunner"
}

data "azurerm_client_config" "current" {}

resource "azapi_resource" "oneespool" {
  for_each = toset(local.repos)

  parent_id = azurerm_resource_group.onees_runner_pool.id
  type      = "Microsoft.CloudTest/hostedpools@2020-05-07"
  body      = jsonencode({
    properties = {
      organizationProfile = {
        type = "GitHub",
        url  = each.value
      }
      networkProfile = {
        natGatewayIpAddressCount = 1
      }
      vmProviderProperties = {
        VssAdminPermissions = "CreatorOnly"
      }
      agentProfile = {
        type = "Stateless"
      }
      maxPoolSize = try(local.repo_pool_max_runners[each.value], 3)
      images      = [
        {
          imageName            = "ghrunner"
          subscriptionId       = data.azurerm_client_config.current.subscription_id
          poolBufferPercentage = "100"
        }
      ]
      sku = {
        name       = "Standard_D2ds_v4"
        tier       = "StandardSSD"
        enableSpot = false
      }
      vmProvider = "Azure"
    }
  })
  location                  = try(local.repo_region[each.value], "eastus")
  name                      = lookup(local.repo_pool_names, each.value, local.repo_names[each.value])
  schema_validation_enabled = false
  tags                      = {
    repo_url = each.value
  }

  timeouts {
    create = "30m"
    delete = "30m"
    read   = "10m"
  }
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "null_resource" "pool_size_keeper" {
  for_each = toset(local.repos)
  triggers = {
    size = try(local.repo_pool_max_runners[each.value], 3)
  }
}

resource "azapi_update_resource" "identity" {
  for_each = toset(local.repos)

  type = "Microsoft.CloudTest/hostedpools@2020-05-07"
  body = jsonencode({
    identity = {
      type                   = "UserAssigned"
      userAssignedIdentities = {
        (azurerm_user_assigned_identity.pool_identity["runner"].id) : {}
      }
    }
  })
  resource_id = azapi_resource.oneespool[each.value].id
  lifecycle {
    replace_triggered_by = [
      null_resource.pool_size_keeper[each.key]
    ]
  }
}

# Onees Pool with Azure Firewall is still WIP. It seems like we cannot share one subnet with multiple pools, so this
# design needs further improvement.

#resource "azapi_resource" "oneespool_fw" {
#  for_each = toset(local.repos_fw)
#
#  parent_id = azurerm_resource_group.onees_runner_pool.id
#  type      = "Microsoft.CloudTest/hostedpools@2020-05-07"
#  body      = jsonencode({
#    properties = {
#      organizationProfile = {
#        type = "GitHub",
#        url  = each.value
#      }
#      networkProfile = {
#        subnetId = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${azurerm_resource_group.onees_runner_pool.name}/providers/Microsoft.Network/virtualNetworks/${azurerm_virtual_network.onees_vnet.name}/subnets/${azurerm_subnet.runner.name}"
#      }
#      vmProviderProperties = {
#        VssAdminPermissions = "CreatorOnly"
#      }
#      agentProfile = {
#        type = "Stateless"
#      }
#      maxPoolSize = 3
#      images      = [
#        {
#          imageName            = "ghrunner"
#          subscriptionId       = data.azurerm_client_config.current.subscription_id
#          poolBufferPercentage = "100"
#        }
#      ]
#      sku = {
#        name       = "Standard_D2ds_v4"
#        tier       = "StandardSSD"
#        enableSpot = false
#      }
#      vmProvider = "Azure"
#    }
#  })
#  location                  = azurerm_resource_group.onees_runner_pool.location
#  name                      = lookup(local.repo_pool_names, each.value, reverse(split("/", each.value))[0])
#  schema_validation_enabled = false
#  tags                      = {
#    repo_url = each.value
#  }
#
#  timeouts {
#    create = "30m"
#    delete = "30m"
#    read   = "10m"
#  }
#}

#resource "azapi_update_resource" "update_after_apply" {
#  for_each = toset(local.repos_fw)
#
#  type = azapi_resource.oneespool_fw[each.key].type
#  body = jsonencode({
#    identity = {
#      type                   = "UserAssigned"
#      userAssignedIdentities = {
#        (azurerm_user_assigned_identity.pool_identity["runner"].id) : {}
#      }
#    }
#  })
#  resource_id = azapi_resource.oneespool_fw[each.value].id
#}

data "azurerm_resource_group" "runner_state" {
  name = "bambrane-runner-state"
}

data azurerm_user_assigned_identity bambrane_operator {
  name                = "bambrane_operator"
  resource_group_name = data.azurerm_resource_group.runner_state.name
}

#data "azurerm_subnet" "bambrane_onees_pool" {
#  name                 = "runner"
#  virtual_network_name = "control-plane-meta-controller"
#  resource_group_name  = data.azurerm_resource_group.runner_state.name
#}

resource "azapi_resource" "onees_meta_pool" {
  parent_id = azurerm_resource_group.onees_runner_pool.id
  type      = "Microsoft.CloudTest/hostedpools@2020-05-07"
  body      = jsonencode({
    properties = {
      organizationProfile = {
        type = "GitHub",
        url  = "https://github.com/Azure/terraform-azure-modules"
      }
      networkProfile = {
        natGatewayIpAddressCount = 1
      }
      vmProviderProperties = {
        VssAdminPermissions = "CreatorOnly"
      }
      agentProfile = {
        type = "Stateless"
      }
      maxPoolSize = 3
      images      = [
        {
          imageName            = "bambrane-runner"
          subscriptionId       = data.azurerm_client_config.current.subscription_id
          poolBufferPercentage = "100"
        }
      ]
      sku = {
        name       = "Standard_D2ds_v4"
        tier       = "StandardSSD"
        enableSpot = false
      }
      vmProvider = "Azure"
    }
  })
  location                  = "eastus"
  name                      = "terraform-azure-modules"
  schema_validation_enabled = false
  tags                      = {
    repo_url = "https://github.com/Azure/terraform-azure-modules"
  }

  timeouts {
    create = "30m"
    delete = "30m"
    read   = "10m"
  }
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "azapi_update_resource" "runner_backend_identity" {
  type = "Microsoft.CloudTest/hostedpools@2020-05-07"
  body = jsonencode({
    identity = {
      type                   = "UserAssigned"
      userAssignedIdentities = {
        (data.azurerm_user_assigned_identity.bambrane_operator.id) : {}
      }
    }
  })
  resource_id = azapi_resource.onees_meta_pool.id
}

resource "azapi_resource" "onees_pool_with_backend" {
  for_each = toset(local.repos_with_backend)

  parent_id = azurerm_resource_group.onees_runner_pool.id
  type      = "Microsoft.CloudTest/hostedpools@2020-05-07"
  body      = jsonencode({
    properties = {
      organizationProfile = {
        type = "GitHub",
        url  = each.value
      }
      networkProfile = {
        natGatewayIpAddressCount = 1
      }
      vmProviderProperties = {
        VssAdminPermissions = "CreatorOnly"
      }
      agentProfile = {
        type = "Stateless"
      }
      maxPoolSize = 3
      images      = [
        {
          imageName            = "bambrane-runner"
          subscriptionId       = data.azurerm_client_config.current.subscription_id
          poolBufferPercentage = "100"
        }
      ]
      sku = {
        name       = "Standard_D2ds_v4"
        tier       = "StandardSSD"
        enableSpot = false
      }
      vmProvider = "Azure"
    }
  })
  location                  = "eastus"
  name                      = lookup(local.repo_pool_names, each.value, reverse(split("/", each.value))[0])
  schema_validation_enabled = false
  tags                      = {
    repo_url = each.value
  }

  timeouts {
    create = "30m"
    delete = "30m"
    read   = "10m"
  }
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "azapi_update_resource" "gitops_runner_backend_identity" {
  for_each = toset(local.repos_with_backend)

  type = "Microsoft.CloudTest/hostedpools@2020-05-07"
  body = jsonencode({
    identity = {
      type                   = "UserAssigned"
      userAssignedIdentities = {
        (data.azurerm_user_assigned_identity.bambrane_operator.id) : {}
      }
    }
  })
  resource_id = azapi_resource.onees_pool_with_backend[each.value].id
}