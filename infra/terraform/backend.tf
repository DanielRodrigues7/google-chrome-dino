terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-lab"
    storage_account_name = "sttfdanieldzhzk9"
    container_name       = "tfstate"
    key                  = "dino/infra.tfstate"
    use_azuread_auth     = true
  }

}
