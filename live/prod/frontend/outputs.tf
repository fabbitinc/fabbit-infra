output "landing_bucket_name" {
  description = "landing 배포용 버킷 이름입니다."
  value       = module.landing.bucket_name
}

output "landing_distribution_domain_name" {
  description = "landing CloudFront 기본 도메인입니다."
  value       = module.landing.distribution_domain_name
}

output "landing_distribution_id" {
  description = "landing CloudFront distribution ID입니다."
  value       = module.landing.distribution_id
}

output "web_bucket_name" {
  description = "web 배포용 버킷 이름입니다."
  value       = module.web.bucket_name
}

output "web_distribution_domain_name" {
  description = "web CloudFront 기본 도메인입니다."
  value       = module.web.distribution_domain_name
}

output "web_distribution_id" {
  description = "web CloudFront distribution ID입니다."
  value       = module.web.distribution_id
}
