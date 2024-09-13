data "azapi_client_config" "current" {}

resource "azapi_resource" "identity-rg" {
  type     = "Microsoft.Resources/resourceGroups@2024-03-01"
  name     = "rg-avm-identities"
  location = "eastus2"
  tags = {
    "do_not_delete" : "",
  }
}

resource "azapi_resource" "identity" {
  for_each  = toset(local.all_repos)
  type      = "Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview"
  parent_id = azapi_resource.identity-rg.id
  name      = "${local.all_repos_parsed[each.value].owner}-${local.all_repos_parsed[each.value].name}"
  location  = azapi_resource.identity-rg.location
  body      = {} # empty body as HCL object is reqired to force output to be HCL and not JSON string.
  response_export_values = [
    "properties.principalId",
    "properties.clientId",
    "properties.tenantId"
  ]
}

resource "azapi_resource" "identity_federated_credentials" {
  for_each  = toset(local.all_repos)
  type      = "Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-07-31-preview"
  name      = "${local.all_repos_parsed[each.value].owner}-${local.all_repos_parsed[each.value].name}"
  parent_id = azapi_resource.identity[each.key].id
  locks     = [azapi_resource.identity[each.key].id] # not needed but added if we configure more than one environment
  body = {
    properties = {
      audiences = ["api://AzureADTokenExchange"]
      issuer    = "https://token.actions.githubusercontent.com"
      subject   = "repo:${local.all_repos_parsed[each.value].owner}/${local.all_repos_parsed[each.value].name}:environment:${local.environment_name}"
    }
  }
}

# Add owner role assignment.
# The condition prevents the assignee from creating new role assignments for owner, user access administratior, or role based access control administrator.
resource "azapi_resource" "identity_role_assignment" {
  for_each  = toset(local.all_repos)
  type      = "Microsoft.Authorization/roleAssignments@2022-04-01"
  name      = uuidv5("url", "${each.value}${data.azapi_client_config.current.subscription_id}${data.azapi_client_config.current.tenant_id}")
  parent_id = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
  body = {
    properties = {
      roleDefinitionId = "/subscriptions/${data.azapi_client_config.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/${local.role_definition_name_owner}"
      principalType    = "ServicePrincipal"
      principalId      = azapi_resource.identity[each.key].output.properties.principalId
      description      = "Role assignment for AVM testing. Repo: ${local.all_repos_parsed[each.value].owner}/${local.all_repos_parsed[each.value].name}"
      conditionVersion = "2.0"
      condition        = <<CONDITION
(
 (
  !(ActionMatches{'Microsoft.Authorization/roleAssignments/write'})
 )
 OR
 (
  @Request[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAllValues:GuidNotEquals {8e3af657-a8ff-443c-a75c-2fe8c4bcb635, 18d7d88d-d35e-4fb5-a5c3-7773c20a72d9, f58310d9-a9f6-439a-9e8d-f62e7b41a168}
 )
)
AND
(
 (
  !(ActionMatches{'Microsoft.Authorization/roleAssignments/delete'})
 )
 OR
 (
  @Resource[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAllValues:GuidNotEquals {8e3af657-a8ff-443c-a75c-2fe8c4bcb635, 18d7d88d-d35e-4fb5-a5c3-7773c20a72d9, f58310d9-a9f6-439a-9e8d-f62e7b41a168}
 )
)
CONDITION
    }
  }
}
