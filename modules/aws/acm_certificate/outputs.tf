output "certificate_arn" {
  description = "발급된 ACM 인증서 ARN입니다."
  value       = aws_acm_certificate.this.arn
}

output "validation_records" {
  description = "DNS 검증용 레코드 정보입니다."
  value = {
    for option in aws_acm_certificate.this.domain_validation_options : option.domain_name => {
      name  = option.resource_record_name
      type  = option.resource_record_type
      value = option.resource_record_value
    }
  }
}
