resource "azurerm_log_analytics_workspace" "example" {
  name                = "acctest-01"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# az provider register --namespace Microsoft.App でプロパイダー登録が必要
resource "azurerm_container_app_environment" "example" {
  name                       = "ac-environment-01"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
}
resource "azurerm_container_app" "example" {
  name                         = var.container_app_name
  container_app_environment_id = azurerm_container_app_environment.example.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  template {
    container {
      name   = "examplecontainerapp"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }
  ingress {
    target_port      = 80
    external_enabled = true
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}