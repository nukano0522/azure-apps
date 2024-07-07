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
}

resource "azurerm_resource_group" "rg01" {
  name     = local.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "sa01" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.rg01.name
  location                 = azurerm_resource_group.rg01.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

// https://learn.microsoft.com/ja-jp/azure/search/search-get-started-terraform
resource "azurerm_search_service" "search" {
  name                = local.ai_search_name
  resource_group_name = azurerm_resource_group.rg01.name
  location            = azurerm_resource_group.rg01.location
  sku                 = var.sku
  replica_count       = var.replica_count
  partition_count     = var.partition_count
}