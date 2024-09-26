#create the github repo
data "github_repository" "this" {
  name = "terraform-azurerm-${var.name}"
}