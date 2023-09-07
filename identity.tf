resource "azurerm_resource_group" "pool_identity" {
  location = "eastus"
  name     = "1es-runner-identity"
}

resource "azurerm_user_assigned_identity" "pool_identity" {
  for_each = local.identities

  location            = azurerm_resource_group.pool_identity.location
  name                = each.value
  resource_group_name = azurerm_resource_group.pool_identity.name
}

resource "azurerm_role_assignment" "verified_module_runner" {
  principal_id         = azurerm_user_assigned_identity.pool_identity["runner"].principal_id
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "Owner"
}

resource "azurerm_role_assignment" "doc_test_runner" {
  principal_id         = azurerm_user_assigned_identity.pool_identity["docrunner"].principal_id
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "Owner"
}

resource "azurerm_role_assignment" "control_plane_test_runner" {
  principal_id         = azurerm_user_assigned_identity.pool_identity["control-plane"].principal_id
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "Owner"
}