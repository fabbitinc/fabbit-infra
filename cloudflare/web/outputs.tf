output "r2_bucket_name" {
  description = "R2 버킷 이름"
  value       = module.r2_storage.bucket_name
}

output "r2_endpoint" {
  description = "R2 S3 호환 엔드포인트"
  value       = module.r2_storage.s3_endpoint
}

output "r2_public_url" {
  description = "R2 퍼블릭 액세스 URL"
  value       = module.r2_storage.public_url
}

output "worker_script_name" {
  description = "배포된 Worker 스크립트 이름"
  value       = cloudflare_workers_script.subdomain_router.script_name
}

output "worker_route_pattern" {
  description = "Worker 라우트 패턴"
  value       = cloudflare_workers_route.subdomain_router.pattern
}
