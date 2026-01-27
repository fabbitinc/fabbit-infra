output "id" {
  description = "컨테이너 레지스트리 ID"
  value       = azurerm_container_registry.this.id
}

output "name" {
  description = "컨테이너 레지스트리 이름"
  value       = azurerm_container_registry.this.name
}

output "login_server" {
  description = "로그인 서버 URL"
  value       = azurerm_container_registry.this.login_server
}

output "admin_username" {
  description = "관리자 사용자 이름"
  value       = azurerm_container_registry.this.admin_username
}

output "admin_password" {
  description = "관리자 비밀번호"
  value       = azurerm_container_registry.this.admin_password
  sensitive   = true
}
