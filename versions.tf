terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 1.15"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.43"
    }
  }
}

provider "azapi" {
  # compatibility with v2.0
  enable_hcl_output_for_data_source = true
}

provider "github" {}
