variable "github_repository_owner" {
  type        = string
  description = "Owner of the GitHub repositories."
  default     = "Azure"
}

variable "module_owner_github_handle" {
  type        = string
  description = "GitHub handle of the module owner."
}

variable "module_id" {
  type        = string
  description = "ID of the AVM (e.g. avm-ptn-alz-managment)"
}

variable "module_name" {
  type        = string
  description = "Description of the AVM (e.g. Azure Landing Zones Management Resources)"
}

variable "github_owner_team_name_postfix" {
  type        = string
  description = "Name of the GitHub owner team."
  default     = "module-owners-tf"
}

variable "github_contributor_team_name_postfix" {
  type        = string
  description = "Name of the GitHub owner team."
  default     = "module-contributors-tf"
}

variable "maintainer_teams" {
  type        = map(string)
  description = "Map of teams that should have maintainers added to the repository."
  default = {
    avm_core      = "avm-core-team-technical-terraform"
    terraform_avm = "terraform-avm"
  }
}
