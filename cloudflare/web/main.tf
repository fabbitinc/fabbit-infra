terraform {
  required_version = ">= 1.6.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.16"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.30"
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
  project = "fabbit"
}

# R2 버킷 - 파일 저장소 (drawings/, documents/ 폴더로 구분)
module "r2_storage" {
  source = "../modules/r2"

  providers = {
    aws.r2 = aws.r2
  }

  account_id  = var.cloudflare_account_id
  bucket_name = "${local.project}-${var.environment}"
  location    = "APAC"

  cors_allowed_origins = var.r2_cors_allowed_origins

  zone_id       = var.cloudflare_zone_id
  custom_domain = var.r2_custom_domain
}
