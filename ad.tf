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

data "azuread_service_principal" "onees_resource_management" {
  display_name = "1ES Resource Management"
}