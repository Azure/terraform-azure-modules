#create the github repo
resource "github_repository" "this" {
  name = "terraform-azurerm-${var.name}"
  visibility = "public"
  vulnerability_alerts = true
  archive_on_destroy = true

  template {
    owner = "Azure"
    repository = var.template_repo_name
    include_all_branches = false
  }
}