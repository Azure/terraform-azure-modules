data "github_repository" "avm_repo" {
  for_each = toset(concat(local.avm_pattern_mod_repos, local.avm_res_mod_repos))

  full_name = trimprefix(each.value, "https://github.com/")
}

locals {
  valid_avm_repos = [for repo in data.github_repository.avm_repo : repo.html_url if repo.html_url != null && repo.html_url != ""]
}