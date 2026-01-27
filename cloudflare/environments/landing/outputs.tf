output "pages_subdomain" {
  description = "랜딩 Pages 서브도메인"
  value       = module.pages_landing.subdomain
}

output "pages_project_name" {
  description = "랜딩 Pages 프로젝트 이름"
  value       = module.pages_landing.project_name
}
