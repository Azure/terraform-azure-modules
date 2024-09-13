output "repos_to_client_ids" {
  value = { for v in toset(local.all_repos) : v => azapi_resource.identity[v].output.properties.clientId }
}
