output "role_arn" {
  description = "GitHub Actions가 assume할 IAM role ARN입니다."
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "GitHub Actions가 assume할 IAM role 이름입니다."
  value       = aws_iam_role.this.name
}

output "oidc_provider_arn" {
  description = "GitHub Actions OIDC provider ARN입니다."
  value       = aws_iam_openid_connect_provider.github_actions.arn
}
