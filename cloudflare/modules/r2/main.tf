terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.16"
    }
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 6.30"
      configuration_aliases = [aws.r2]
    }
  }
}

# Cloudflare R2 버킷 생성
resource "cloudflare_r2_bucket" "this" {
  account_id = var.account_id
  name       = var.bucket_name
  location   = var.location
}

# S3 호환 API를 통한 CORS 설정
resource "aws_s3_bucket_cors_configuration" "this" {
  provider = aws.r2
  bucket   = cloudflare_r2_bucket.this.name

  cors_rule {
    allowed_headers = var.cors_allowed_headers
    allowed_methods = var.cors_allowed_methods
    allowed_origins = var.cors_allowed_origins
    expose_headers  = var.cors_expose_headers
    max_age_seconds = var.cors_max_age_seconds
  }

  depends_on = [cloudflare_r2_bucket.this]
}
