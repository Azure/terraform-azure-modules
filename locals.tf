locals {
  identities = toset([
    "runner",
    "docrunner",
    "control-plane",
  ])

  avm_res_mod_csv       = file("${path.module}/Azure-Verified-Modules/docs/static/module-indexes/TerraformResourceModules.csv")
  avm_pattern_mod_csv   = file("${path.module}/Azure-Verified-Modules/docs/static/module-indexes/TerraformPatternModules.csv")
  avm_res_mod_repos     = [for i in csvdecode(local.avm_res_mod_csv) : i.RepoURL]
  avm_pattern_mod_repos = [for i in csvdecode(local.avm_pattern_mod_csv) : i.RepoURL]
  legacy_repos = toset([
    "https://github.com/Azure/terraform-azurerm-aks",
    "https://github.com/Azure/terraform-azurerm-compute",
    "https://github.com/Azure/terraform-azurerm-loadbalancer",
    "https://github.com/Azure/terraform-azurerm-network",
    "https://github.com/Azure/terraform-azurerm-network-security-group",
    "https://github.com/Azure/terraform-azurerm-postgresql",
    "https://github.com/Azure/terraform-azurerm-subnets",
    "https://github.com/Azure/terraform-azurerm-vnet",
    "https://github.com/Azure/terraform-azurerm-virtual-machine",
    "https://github.com/Azure/terraform",
    "https://github.com/Azure/terraform-azurerm-hubnetworking",
    "https://github.com/Azure/terraform-azurerm-openai",
    "https://github.com/Azure/terraform-azure-mdc-defender-plans-azure",
    "https://github.com/Azure/terraform-azurerm-database",
    "https://github.com/Azure/terraform-azure-container-apps",
    "https://github.com/Azure/terraform-azurerm-avm-res-storage-storageaccounts",
    "https://github.com/Azure/terraform-azurerm-avm-res-keyvault-vault",
    "https://github.com/Azure/avm-gh-app",
    "https://github.com/Azure/oneesrunnerscleaner",
  ])
  all_repos = setunion(local.legacy_repos, local.valid_avm_repos)
  all_repos_parsed = {
    for r in toset(local.all_repos) : r => {
      name  = reverse(split("/", r))[0]
      owner = reverse(split("/", r))[1]
    }
  }

  environment_name           = "test"
  role_definition_name_owner = "8e3af657-a8ff-443c-a75c-2fe8c4bcb635"
}
