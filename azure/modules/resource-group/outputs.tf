output "name" {
  description = "리소스 그룹 이름"
  value       = azurerm_resource_group.this.name
}

output "location" {
  description = "리소스 그룹 위치"
  value       = azurerm_resource_group.this.location
}

output "id" {
  description = "리소스 그룹 ID"
  value       = azurerm_resource_group.this.id
}
