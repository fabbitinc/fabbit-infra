output "r2_bucket_name" {
  description = "R2 버킷 이름"
  value       = module.r2_storage.bucket_name
}

output "r2_endpoint" {
  description = "R2 엔드포인트"
  value       = module.r2_storage.s3_endpoint
}
