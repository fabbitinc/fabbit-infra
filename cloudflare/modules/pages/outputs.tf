output "project_name" {
  description = "Pages 프로젝트 이름"
  value       = cloudflare_pages_project.this.name
}

output "subdomain" {
  description = "Pages 기본 서브도메인"
  value       = cloudflare_pages_project.this.subdomain
}

output "domains" {
  description = "Pages 도메인 목록"
  value       = cloudflare_pages_project.this.domains
}
