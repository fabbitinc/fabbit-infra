# EC2
output "ec2_public_ip" {
  description = "EC2 Elastic IP 주소"
  value       = module.ec2.public_ip
}

output "ec2_instance_id" {
  description = "EC2 인스턴스 ID"
  value       = module.ec2.instance_id
}

output "ec2_security_group_id" {
  description = "EC2 Security Group ID (GitHub Actions 배포에 사용)"
  value       = module.ec2.security_group_id
}

output "api_domain" {
  description = "API 도메인"
  value       = "${var.api_subdomain}.${var.app_domain}"
}

# R2
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

# Worker
output "worker_script_name" {
  description = "배포된 Worker 스크립트 이름"
  value       = cloudflare_workers_script.subdomain_router.script_name
}

output "worker_route_pattern" {
  description = "Worker 라우트 패턴"
  value       = cloudflare_workers_route.subdomain_router.pattern
}

# CI
output "github_actions_role_arn" {
  description = "GitHub Actions OIDC Role ARN (repo secrets에 설정)"
  value       = aws_iam_role.github_actions.arn
}

# SES
output "ses_domain_identity_arn" {
  description = "SES 도메인 ARN (앱 설정 시 참고)"
  value       = var.ses_enabled ? aws_sesv2_email_identity.domain[0].arn : null
}

output "ses_sending_enabled" {
  description = "SES 활성화 여부"
  value       = var.ses_enabled
}
