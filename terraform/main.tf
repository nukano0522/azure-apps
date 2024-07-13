provider "azurerm" {
  subscription_id = var.provider_credentials.subscription_id
  tenant_id       = var.provider_credentials.tenant_id
  client_id       = var.provider_credentials.sp_client_id
  client_secret   = var.provider_credentials.sp_client_secret
  features {}
}

locals {
  resource_group_name       = "rg-nukano0522-01"
  storage_account_name = "sanukano052201"
  ai_search_name = "aisearchnukano052201"
  container_registry_name = "containerregistrynukano052201"
  container_app_name = "containerappnukano052201"
}

module "resource_group" {
  source = "./modules/resource_group"
  resource_group_name = local.resource_group_name
  location = var.location
}

# module "storage_account" {
#   source = "./modules/storage_account"
#   storage_account_name = local.storage_account_name
#   resource_group_name = module.resource_group.name
#   location = var.location
# }

# module "container_registry" {
#   source = "./modules/container_registry"
#   container_registry_name = local.container_registry_name
#   resource_group_name = module.resource_group.name
#   location = var.location
# }

module "container_app" {
  source = "./modules/container_app"
  container_app_name = local.container_app_name
  container_registry_name = local.container_registry_name
  resource_group_name = module.resource_group.name
  location = var.location
}

## https://learn.microsoft.com/ja-jp/azure/search/search-get-started-terraform
# resource "azurerm_search_service" "search" {
#   name                = local.ai_search_name
#   resource_group_name = azurerm_resource_group.rg01.name
#   location            = azurerm_resource_group.rg01.location
#   sku                 = var.sku
#   replica_count       = var.replica_count
#   partition_count     = var.partition_count
# }