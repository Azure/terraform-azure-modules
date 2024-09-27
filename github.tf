data "github_repository" "this" {
  full_name = "${var.github_repository_owner}/${var.github_repository_name}"
}

data "github_team" "avm_core" {
  count = var.manage_github_environment ? 1 : 0
  slug = var.github_core_team_name
}

data "github_team" "owners" {
  count = var.manage_github_environment ? 1 : 0
  slug = replace(var.github_owner_team_name, "@Azure/", "")
}

resource "github_repository_environment" "this" {
  count               = var.manage_github_environment ? 1 : 0
  environment         = var.github_repository_environment_name
  repository          = data.github_repository.this.name
  reviewers {
    teams = [
      data.github_team.avm_core[0].id,
      data.github_team.owners[0].id
    ]
  }
  deployment_branch_policy {
    protected_branches     = true
    custom_branch_policies = false
  }
}

resource "github_actions_environment_secret" "tenant_id" {
  count             = var.manage_github_environment ? 1 : 0
  repository        = data.github_repository.this.name
  environment       = github_repository_environment.this[0].environment
  secret_name       = "ARM_TENANT_ID"
  plaintext_value   = data.azapi_client_config.current.tenant_id
}

resource "github_actions_environment_secret" "subscription_id" {
  count             = var.manage_github_environment ? 1 : 0
  repository        = data.github_repository.this.name
  environment       = github_repository_environment.this[0].environment
  secret_name       = "ARM_SUBSCRIPTION_ID"
  plaintext_value   = data.azapi_client_config.current.subscription_id
}

resource "github_actions_environment_secret" "client_id" {
  count             = var.manage_github_environment ? 1 : 0
  repository        = data.github_repository.this.name
  environment       = github_repository_environment.this[0].environment
  secret_name       = "ARM_CLIENT_ID"
  plaintext_value   = azapi_resource.identity.output.properties.clientId
}