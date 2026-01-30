terraform {
  required_version = ">= 1.6.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.16"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# R2 CORS 설정을 위한 S3 호환 API Provider
provider "aws" {
  alias = "r2"

  access_key = var.r2_access_key_id
  secret_key = var.r2_secret_access_key

  skip_credentials_validation = true
  skip_region_validation      = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true

  endpoints {
    s3 = "https://${var.cloudflare_account_id}.r2.cloudflarestorage.com"
  }

  region = "auto"
}

locals {
  project     = "fabbit"
  environment = "prod"
}

# R2 버킷 - 파일 저장소 (drawings/, documents/ 폴더로 구분)
module "r2_storage" {
  source = "../../modules/r2"

  providers = {
    aws.r2 = aws.r2
  }

  account_id  = var.cloudflare_account_id
  bucket_name = "${local.project}-${local.environment}"
  location    = "APAC"

  cors_allowed_origins = var.cors_allowed_origins
}

# Cloudflare Pages - 앱 프론트엔드 (Direct Upload 방식)
# GitHub Actions에서 빌드 후 wrangler pages deploy로 배포
module "pages_app" {
  source = "../../modules/pages"

  account_id        = var.cloudflare_account_id
  project_name      = "${local.project}-web-${local.environment}"
  production_branch = "main"

  production_env_vars = {
    VITE_API_URL = var.api_url
  }

  preview_env_vars = {}
}
