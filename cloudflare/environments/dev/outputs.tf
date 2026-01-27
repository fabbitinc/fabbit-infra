output "r2_bucket_name" {
  description = "R2 버킷 이름"
  value       = module.r2_storage.bucket_name
}

output "r2_endpoint" {
  description = "R2 S3 호환 엔드포인트"
  value       = module.r2_storage.s3_endpoint
}

output "pages_subdomain" {
  description = "Pages 서브도메인"
  value       = module.pages.subdomain
}

output "pages_project_name" {
  description = "Pages 프로젝트 이름"
  value       = module.pages.project_name
}
