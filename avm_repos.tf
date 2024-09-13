data "github_repository" "avm_repo" {
  for_each = toset(concat(local.avm_pattern_mod_repos, local.avm_res_mod_repos))

  full_name = trimprefix(each.value, "https://github.com/")
}

locals {
  avm_repos       = toset([for repo in data.github_repository.avm_repo : repo.html_url])
  valid_avm_repos = [for r in local.avm_repos : r if r != "" && r != null]
}
