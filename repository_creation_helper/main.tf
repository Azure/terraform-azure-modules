locals {
  github_repository_name        = "terraform-azurerm-${var.module_id}"
  github_reposisory_description = "Terraform Azure Verified Module for ${var.module_name}"
}

import {
  id = local.github_repository_name
  to = github_repository.this
}

resource "github_repository" "this" {
  name        = local.github_repository_name
  description = local.github_reposisory_description
  auto_init   = false

  visibility   = "public"
  homepage_url = "https://registry.terraform.io/modules/Azure/${var.module_id}"

  template {
    owner                = "Azure"
    repository           = "terraform-azurerm-avm-template"
    include_all_branches = false
  }

  has_issues             = true
  has_discussions        = false
  has_projects           = false
  has_wiki               = false
  allow_merge_commit     = false
  allow_squash_merge     = true
  allow_rebase_merge     = false
  allow_auto_merge       = true
  delete_branch_on_merge = true
  allow_update_branch    = true
  vulnerability_alerts   = false

  security_and_analysis {
    secret_scanning {
      status = "enabled"
    }
    secret_scanning_push_protection {
      status = "enabled"
    }
  }
}

resource "github_team" "owners" {
  name                      = "${var.module_id}-${var.github_owner_team_name_postfix}"
  description               = "Owners of the ${var.module_id} Azure Verified Module."
  privacy                   = "closed"
  create_default_maintainer = true
}

resource "github_team" "contributors" {
  name                      = "${var.module_id}-${var.github_contributor_team_name_postfix}"
  description               = "Contributors of the ${var.module_id} Azure Verified Module."
  privacy                   = "closed"
  create_default_maintainer = true
}

resource "github_team_membership" "owners_maintainer" {
  team_id  = github_team.owners.id
  username = var.module_owner_github_handle
  role     = "maintainer"
}

resource "github_team_membership" "contributors_maintainer" {
  team_id  = github_team.contributors.id
  username = var.module_owner_github_handle
  role     = "maintainer"
}

data "github_team" "avm_core" {
  for_each = var.maintainer_teams
  slug     = each.value
}

resource "github_team_repository" "avm_core" {
  for_each   = data.github_team.avm_core
  team_id    = each.value.id
  repository = github_repository.this.name
  permission = "maintain"
}

resource "github_team_repository" "owners_team" {
  team_id    = github_team.owners.id
  repository = github_repository.this.name
  permission = "maintain"
}

resource "github_team_repository" "contributors_team" {
  team_id    = github_team.contributors.id
  repository = github_repository.this.name
  permission = "push"
}