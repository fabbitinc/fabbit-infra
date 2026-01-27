output "r2_bucket_name" {
  description = "R2 버킷 이름"
  value       = module.r2_storage.bucket_name
}

output "r2_endpoint" {
  description = "R2 S3 호환 엔드포인트"
  value       = module.r2_storage.s3_endpoint
}

# 앱 프론트엔드
output "pages_app_subdomain" {
  description = "앱 Pages 서브도메인"
  value       = module.pages_app.subdomain
}

output "pages_app_project_name" {
  description = "앱 Pages 프로젝트 이름"
  value       = module.pages_app.project_name
}
