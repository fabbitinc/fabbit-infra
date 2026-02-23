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
