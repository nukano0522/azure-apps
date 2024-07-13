# resource "azurerm_user_assigned_identity" "example" {
#   name                = "acr-user"
#   resource_group_name = var.resource_group_name
#   location            = var.location
# }

resource "azurerm_container_registry" "acr" {
  name                = var.container_registry_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  # sku                 = "Premium"
  admin_enabled       = true
}

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
  # identity {
  #   type = "UserAssigned"
  #   identity_ids = [azurerm_user_assigned_identity.example.id]
  # }

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
  # https://github.com/hashicorp/terraform-provider-azurerm/issues/21766
  secret {
    name  = "registry-credentials"
    value = azurerm_container_registry.acr.admin_password
  }
  registry {
    server   = azurerm_container_registry.acr.login_server
    username = azurerm_container_registry.acr.admin_username
    password_secret_name = "registry-credentials"
  }
}