output "resource_group_name" {
  description = "리소스 그룹 이름"
  value       = module.resource_group.name
}

output "postgresql_server_fqdn" {
  description = "PostgreSQL 서버 FQDN"
  value       = module.postgresql.server_fqdn
}

output "postgresql_database_name" {
  description = "PostgreSQL 데이터베이스 이름"
  value       = module.postgresql.database_name
}

output "container_registry_login_server" {
  description = "컨테이너 레지스트리 로그인 서버"
  value       = module.container_registry.login_server
}

output "container_app_url" {
  description = "Container App URL"
  value       = module.container_app.url
}

output "key_vault_uri" {
  description = "Key Vault URI"
  value       = module.key_vault.vault_uri
}
