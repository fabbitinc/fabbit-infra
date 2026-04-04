output "r2_bucket_name" {
  description = "R2 버킷 이름"
  value       = module.r2_storage.bucket_name
}

output "r2_endpoint" {
  description = "R2 엔드포인트"
  value       = module.r2_storage.s3_endpoint
}

output "r2_public_url" {
  description = "R2 퍼블릭 URL"
  value       = module.r2_storage.public_url
}
