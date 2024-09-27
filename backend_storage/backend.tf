terraform {
  backend "azurerm" {
    storage_account_name = "tfmod1espoolstatestorage"
    resource_group_name  = "bambrane-runner-state"
    container_name       = "azure-verified-tfmod-runner-state"
    key                  = "backend.terraform.tfstate"
    snapshot             = true
    use_msi              = true
  }
}