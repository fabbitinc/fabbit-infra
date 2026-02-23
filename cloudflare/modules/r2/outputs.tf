output "bucket_name" {
  description = "R2 버킷 이름"
  value       = cloudflare_r2_bucket.this.name
}

output "bucket_id" {
  description = "R2 버킷 ID"
  value       = cloudflare_r2_bucket.this.id
}

output "s3_endpoint" {
  description = "S3 호환 API 엔드포인트"
  value       = "https://${var.account_id}.r2.cloudflarestorage.com"
}

output "public_url" {
  description = "R2 퍼블릭 액세스 URL"
  value       = var.custom_domain != null ? "https://${var.custom_domain}" : null
}
