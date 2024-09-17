terraform {
  required_version = "~> 1.9" # Align with the latest tested Terraform version
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.3"
    }
  }
}

/*
#set the provider to use Azure repo when calling from a root module as needed
provider "github" {
    owner = var.repo_owner
}
*/