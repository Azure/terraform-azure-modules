resource "github_repository_environment" "test" {
  environment = var.test_environment_name
  repository  = data.github_repository.this.name
}

resource "github_actions_environment_secret" "tnis" {
  for_each = var.test_environment_secrets

  repository      = data.github_repository.this.name
  environment     = each.value.environment_name
  secret_name     = each.value.secret_name
  plaintext_value = each.value.plaintext_value

  depends_on = [ github_repository_environment.test ]
}
