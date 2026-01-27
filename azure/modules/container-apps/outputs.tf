output "environment_id" {
  description = "Container App Environment ID"
  value       = azurerm_container_app_environment.this.id
}

output "environment_name" {
  description = "Container App Environment 이름"
  value       = azurerm_container_app_environment.this.name
}

output "container_app_id" {
  description = "Container App ID"
  value       = azurerm_container_app.this.id
}

output "container_app_name" {
  description = "Container App 이름"
  value       = azurerm_container_app.this.name
}

output "fqdn" {
  description = "Container App FQDN"
  value       = azurerm_container_app.this.ingress[0].fqdn
}

output "url" {
  description = "Container App URL"
  value       = "https://${azurerm_container_app.this.ingress[0].fqdn}"
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = azurerm_log_analytics_workspace.this.id
}
