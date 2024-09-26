locals {
    team_map = {
        module_owners = {
            name = "${var.name}-owners-tf"
            description = "AVM module ${var.name} owners team"
            permission = "admin"
            type = "new"
        }
        module_contributors = {
            name = "${var.name}-contributors-tf"
            description = "AVM module ${var.name} contributors team"
            permission = "admin"
            type = "new"
        }
        core_team_technical_terraform = {
            name = "avm-core-team-technical-terraform"
            description = "The AVM Terraform core technical team"
            permission = "admin"
            type = "existing"
        }
        terraform_pg = {
            name = "terraform-avm"
            description = "The MS Terraform PG team"
            permission = "admin"
            type = "existing"
        }
    }
}

resource "github_team" "new_teams" {
  for_each = {for k,v in local.team_map : k => v if v.type == "new"}

  name        = each.value.name
  description = each.value.description
  create_default_maintainer = true
  privacy     = "closed"
}

resource "github_repository_collaborators" "some_repo_collaborators" {
  repository = data.github_repository.this.name

  user {
    permission = "admin"
    username = var.owner_gh_alias    
  }  
  
  dynamic team {
    for_each = local.team_map

    content {
        permission = team.value.permission
        team_id = team.value.name
    }
  }

  depends_on = [ github_team.new_teams ]
}

resource "github_team_membership" "default_owner" {
  team_id  = github_team.new_teams["module_owners"].id
  role     = "maintainer" #check if we want to have a default owner in the future?
  username = var.owner_gh_alias
}
