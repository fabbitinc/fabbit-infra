terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.30"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.16"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
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

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

locals {
  project = "fabbit"
}
