output "ec2_public_ip" {
  description = "EC2 Elastic IP 주소"
  value       = module.ec2.public_ip
}

output "ec2_instance_id" {
  description = "EC2 인스턴스 ID"
  value       = module.ec2.instance_id
}

output "api_domain" {
  description = "API 도메인"
  value       = "${var.api_subdomain}.${var.domain}"
}

output "ec2_security_group_id" {
  description = "EC2 Security Group ID (GitHub Actions 배포에 사용)"
  value       = module.ec2.security_group_id
}

output "github_actions_role_arn" {
  description = "GitHub Actions OIDC Role ARN (repo secrets에 설정)"
  value       = aws_iam_role.github_actions.arn
}
