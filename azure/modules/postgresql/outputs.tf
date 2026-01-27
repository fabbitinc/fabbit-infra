output "server_id" {
  description = "PostgreSQL 서버 ID"
  value       = azurerm_postgresql_flexible_server.this.id
}

output "server_name" {
  description = "PostgreSQL 서버 이름"
  value       = azurerm_postgresql_flexible_server.this.name
}

output "server_fqdn" {
  description = "PostgreSQL 서버 FQDN"
  value       = azurerm_postgresql_flexible_server.this.fqdn
}

output "database_name" {
  description = "데이터베이스 이름"
  value       = azurerm_postgresql_flexible_server_database.this.name
}

output "connection_string" {
  description = "PostgreSQL 연결 문자열"
  value       = "postgresql://${var.administrator_login}@${azurerm_postgresql_flexible_server.this.name}:${var.administrator_password}@${azurerm_postgresql_flexible_server.this.fqdn}:5432/${azurerm_postgresql_flexible_server_database.this.name}?sslmode=require"
  sensitive   = true
}

output "administrator_login" {
  description = "관리자 로그인"
  value       = azurerm_postgresql_flexible_server.this.administrator_login
}
