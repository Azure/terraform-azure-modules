terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 1.15"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.53"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.3"
    }
  }
}

provider "azapi" {
  # compatibility with v2.0
  enable_hcl_output_for_data_source = true
}

provider "github" {
  owner = var.github_repository_owner
}
