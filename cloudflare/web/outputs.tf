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
