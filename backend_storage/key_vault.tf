data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "state_storage" {
  name                       = "azmodbackend"
  location                   = azurerm_resource_group.state_rg.location
  resource_group_name        = azurerm_resource_group.state_rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 7
  purge_protection_enabled   = true
  sku_name                   = "standard"
}

resource "azurerm_key_vault_access_policy" "identity" {
  key_vault_id = azurerm_key_vault.state_storage.id
  object_id    = azurerm_user_assigned_identity.state_storage_account.principal_id
  tenant_id    = azurerm_user_assigned_identity.state_storage_account.tenant_id
  key_permissions = [
    "Get",
    "UnwrapKey",
    "WrapKey",
  ]
}

resource "azurerm_key_vault_access_policy" "current_user" {
  key_vault_id = azurerm_key_vault.state_storage.id
  object_id    = coalesce(var.managed_identity_principal_id, data.azurerm_client_config.current.object_id)
  tenant_id    = data.azurerm_client_config.current.tenant_id
  key_permissions = [
    "Get",
    "Recover",
    "Create",
    "Delete",
    "GetRotationPolicy",
  ]
}

resource "azurerm_key_vault_key" "storage_encryption_key" {
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
  key_type     = "RSA"
  key_vault_id = azurerm_key_vault.state_storage.id
  name         = "storageaccount"
  key_size     = 2048

  depends_on = [azurerm_key_vault_access_policy.current_user, azurerm_key_vault_access_policy.identity]
}
