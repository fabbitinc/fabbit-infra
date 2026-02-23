output "public_ip" {
  description = "Elastic IP 주소"
  value       = aws_eip.this.public_ip
}

output "instance_id" {
  description = "EC2 인스턴스 ID"
  value       = aws_instance.this.id
}

output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.this.id
}
