data "azuread_directory_roles" "roles" {}

locals {
  ad_role_names = toset([
    "User Administrator",
    "Groups Administrator",
    "Application Administrator",
  ])
  ad_roles = {
    for r in data.azuread_directory_roles.roles.roles : r.display_name => r.object_id
  }
}

resource "terraform_data" "roles_keeper" {
  triggers_replace = local.ad_roles
}

resource "azuread_directory_role_assignment" "role_binding" {
  for_each = local.ad_role_names

  directory_scope_id  = "/"
  role_id             = local.ad_roles[each.value]
  principal_object_id = azurerm_user_assigned_identity.bambrane_operator.principal_id

  lifecycle {
    ignore_changes       = [role_id]
    replace_triggered_by = [terraform_data.roles_keeper]
  }
}

data "azuread_service_principal" "onees_rm" {
  display_name = "1ES Resource Management"
}