resource "azurerm_resource_group" "state_rg" {
  location = "eastus"
  name     = "bambrane-runner-state"
}

resource "azurerm_user_assigned_identity" "state_storage_account" {
  location            = azurerm_resource_group.state_rg.location
  name                = "state-storage-account"
  resource_group_name = azurerm_resource_group.state_rg.name
}

resource "azurerm_storage_account" "state" {
  account_replication_type      = "ZRS"
  account_tier                  = "Standard"
  account_kind                  = "StorageV2"
  location                      = azurerm_resource_group.state_rg.location
  name                          = "tfmod1espoolstatestorage"
  resource_group_name           = azurerm_resource_group.state_rg.name
  public_network_access_enabled = true

  customer_managed_key {
    key_vault_key_id          = azurerm_key_vault_key.storage_encryption_key.id
    user_assigned_identity_id = azurerm_user_assigned_identity.state_storage_account.id
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.state_storage_account.id]
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_container" "state" {
  name                  = "azure-verified-tfmod-runner-state"
  storage_account_name  = azurerm_storage_account.state.name
  container_access_type = "private"

  lifecycle {
    prevent_destroy = true
    postcondition {
      condition     = self.container_access_type == "private"
      error_message = "this blob container's access type must be `private`."
    }
  }
}

resource "azurerm_storage_container" "plan" {
  name                  = "azure-verified-tfmod-pull-request-plans"
  storage_account_name  = azurerm_storage_account.state.name
  container_access_type = "private"

  lifecycle {
    prevent_destroy = true
    postcondition {
      condition     = self.container_access_type == "private"
      error_message = "this blob container's access type must be `private`."
    }
  }
}

resource "azurerm_storage_account" "bambrane_provision_script" {
  account_replication_type      = "ZRS"
  account_tier                  = "Standard"
  account_kind                  = "StorageV2"
  location                      = azurerm_resource_group.state_rg.location
  name                          = "bambraneprovisionscript"
  resource_group_name           = azurerm_resource_group.state_rg.name
  public_network_access_enabled = true

  customer_managed_key {
    key_vault_key_id          = azurerm_key_vault_key.storage_encryption_key.id
    user_assigned_identity_id = azurerm_user_assigned_identity.state_storage_account.id
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.state_storage_account.id]
  }

  lifecycle {
    prevent_destroy = true
  }
}

#Azure Active Directory authorization must be enabled for your blob storage container.
#Authentication method must be set to Azure AD User Account for your container
#For now I cannot find the corresponding Terraform argument yet, I set this argument via GUI.
resource "azurerm_storage_container" "provision_script" {
  name                  = "onees-provison-script"
  storage_account_name  = azurerm_storage_account.bambrane_provision_script.name
  container_access_type = "private"

  lifecycle {
    prevent_destroy = true
    postcondition {
      condition     = self.container_access_type == "private"
      error_message = "this blob container's access type must be `private`."
    }
  }
}

resource "azurerm_storage_blob" "provision_script" {
  name                   = "Setup.sh"
  storage_account_name   = azurerm_storage_account.bambrane_provision_script.name
  storage_container_name = azurerm_storage_container.provision_script.name
  type                   = "Block"
  access_tier            = "Cool"
  content_type           = "text/x-sh"
  source_content         = "echo MSI_ID=\"${azurerm_user_assigned_identity.bambrane_operator.principal_id}\" >> /etc/environment"

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_role_assignment" "onees_rm_blob_reader" {
  principal_id         = data.azuread_service_principal.onees_rm.object_id
  scope                = azurerm_storage_account.bambrane_provision_script.id
  role_definition_name = "Storage Blob Data Reader"
}

resource "azurerm_user_assigned_identity" "bambrane_operator" {
  location            = azurerm_resource_group.state_rg.location
  name                = "bambrane_operator"
  resource_group_name = azurerm_resource_group.state_rg.name
}

locals {
  storage_accounts = {
    state            = azurerm_storage_account.state.id
    provision_script = azurerm_storage_account.bambrane_provision_script.id
  }
}

resource "azurerm_role_assignment" "storage_contributor" {
  for_each = local.storage_accounts

  principal_id         = azurerm_user_assigned_identity.bambrane_operator.principal_id
  scope                = each.value
  role_definition_name = "Storage Blob Data Contributor"
}

data "azurerm_client_config" "this" {}

resource "azurerm_role_assignment" "subscription_contributor" {
  principal_id         = azurerm_user_assigned_identity.bambrane_operator.principal_id
  scope                = "/subscriptions/${data.azurerm_client_config.this.subscription_id}"
  role_definition_name = "Contributor"
}

