terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.3"
    }
  }
}


provider "github" {
  owner = var.github_repository_owner
}
