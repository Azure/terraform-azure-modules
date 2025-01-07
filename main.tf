data "azapi_client_config" "current" {}

resource "azapi_resource" "identity" {
  type      = "Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview"
  parent_id = "/subscriptions/${data.azapi_client_config.current.subscription_id}/resourceGroups/${var.identity_resource_group_name}"
  name      = "${var.github_repository_owner}-${var.github_repository_name}"
  location  = var.location
  body      = {} # empty body as HCL object is reqired to force output to be HCL and not JSON string.
  response_export_values = [
    "properties.principalId",
    "properties.clientId",
    "properties.tenantId"
  ]
}

resource "azapi_resource" "identity_federated_credentials" {
  type      = "Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-07-31-preview"
  name      = "${var.github_repository_owner}-${var.github_repository_name}"
  parent_id = azapi_resource.identity.id
  locks     = [azapi_resource.identity.id] # not needed but added if we configure more than one environment
  body = {
    properties = {
      audiences = ["api://AzureADTokenExchange"]
      issuer    = "https://token.actions.githubusercontent.com"
      subject   = "repo:${var.github_repository_owner}/${var.github_repository_name}:environment:${var.github_repository_environment_name}"
    }
  }
}

# Add owner role assignment.
# The condition prevents the assignee from creating new role assignments for owner, user access administratior, or role based access control administrator.
resource "azapi_resource" "identity_role_assignment" {
  type      = "Microsoft.Authorization/roleAssignments@2022-04-01"
  name      = uuidv5("url", "${var.github_repository_owner}${var.github_repository_name}${var.target_subscription_id}${data.azapi_client_config.current.tenant_id}")
  parent_id = "/subscriptions/${var.target_subscription_id}"
  body = {
    properties = {
      roleDefinitionId = "/subscriptions/${var.target_subscription_id}/providers/Microsoft.Authorization/roleDefinitions/${local.role_definition_name_owner}"
      principalType    = "ServicePrincipal"
      principalId      = azapi_resource.identity.output.properties.principalId
      description      = "Role assignment for AVM testing. Repo: ${var.github_repository_owner}/${var.github_repository_name}"
      conditionVersion = "2.0"
      condition        = <<CONDITION
(
 (
  !(ActionMatches{'Microsoft.Authorization/roleAssignments/write'})
 )
 OR
 (
  @Request[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAllValues:GuidNotEquals {18d7d88d-d35e-4fb5-a5c3-7773c20a72d9, f58310d9-a9f6-439a-9e8d-f62e7b41a168}
 )
)
AND
(
 (
  !(ActionMatches{'Microsoft.Authorization/roleAssignments/delete'})
 )
 OR
 (
  @Resource[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAllValues:GuidNotEquals {18d7d88d-d35e-4fb5-a5c3-7773c20a72d9, f58310d9-a9f6-439a-9e8d-f62e7b41a168}
 )
)
CONDITION
    }
  }
}

data "azuread_group" "entra_readers" {
  display_name     = "grp-sec-avm-tf-end-to-end-testing-entra-readers"
}

resource "azuread_group_member" "example" {
  group_object_id  = data.azuread_group.entra_readers.object_id
  member_object_id = azapi_resource.identity.output.properties.principalId
}
