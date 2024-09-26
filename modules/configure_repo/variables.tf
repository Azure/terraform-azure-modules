variable "name" {
  type = string
  description = "The name root to use for creating repos and artifacts.  Example. avm-res-sql-server"
}

variable "repo_owner" {
    type = string
    description = "The Owner value to use when creating a new repo. Defaults to Azure."
    default = "Azure"  
}


variable "owner_gh_alias" {
  type = string
  description = "The github alias to use as the owner of this AVM module repo"
}

variable "labels_download_url" {
    type = string
    description = "The location of the labels csv file"
    default = "https://azure.github.io/Azure-Verified-Modules/governance/avm-standard-github-labels.csv"  
}

variable "template_repo_name" {
    type = string
    description = "The name of the template repo to use when creating new AVM repos."
    default = "terraform-azurerm-avm-template"  
}

variable "test_environment_secrets" {
    type = map(object({
        environment_name = optional(string, "test")
        secret_name = string
        plaintext_value = string
    }))  
}

variable "test_environment_name" {
  type = string
  description = "The name for the test environment"
  default = "test"
}

variable "template_copy_branch_name" {
  type = string
  description = "The new branch to create for copying the template files"
  default = "template-files"
}