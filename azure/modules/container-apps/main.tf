resource "azurerm_log_analytics_workspace" "this" {
  name                = "${var.name}-logs"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days

  tags = var.tags
}

resource "azurerm_container_app_environment" "this" {
  name                       = "${var.name}-env"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  tags = var.tags
}

resource "azurerm_container_app" "this" {
  name                         = var.name
  container_app_environment_id = azurerm_container_app_environment.this.id
  resource_group_name          = var.resource_group_name
  revision_mode                = var.revision_mode

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = var.container_name
      image  = var.container_image
      cpu    = var.cpu
      memory = var.memory

      dynamic "env" {
        for_each = var.environment_variables
        content {
          name        = env.key
          value       = env.value.value
          secret_name = env.value.secret_name
        }
      }
    }
  }

  ingress {
    external_enabled = var.external_enabled
    target_port      = var.target_port
    transport        = "http"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  dynamic "secret" {
    for_each = var.secrets
    content {
      name  = secret.key
      value = secret.value
    }
  }

  dynamic "registry" {
    for_each = var.container_registry_server != null ? [1] : []
    content {
      server               = var.container_registry_server
      username             = var.container_registry_username
      password_secret_name = var.container_registry_password_secret_name
    }
  }

  tags = var.tags
}
