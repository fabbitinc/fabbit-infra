output "bucket_name" {
  description = "S3 버킷 이름입니다."
  value       = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  description = "S3 버킷 ARN입니다."
  value       = aws_s3_bucket.this.arn
}

output "distribution_id" {
  description = "CloudFront distribution ID입니다."
  value       = aws_cloudfront_distribution.this.id
}

output "distribution_arn" {
  description = "CloudFront distribution ARN입니다."
  value       = aws_cloudfront_distribution.this.arn
}

output "distribution_domain_name" {
  description = "CloudFront 기본 도메인입니다."
  value       = aws_cloudfront_distribution.this.domain_name
}

output "distribution_hosted_zone_id" {
  description = "CloudFront alias용 hosted zone ID입니다."
  value       = aws_cloudfront_distribution.this.hosted_zone_id
}
