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

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

locals {
  project = "fabbit"
}

# EC2 인스턴스 (Docker Compose로 API + DB 운영)
module "ec2" {
  source = "./modules/ec2"

  environment       = var.environment
  project           = local.project
  instance_type     = var.instance_type
  ssh_public_key    = var.ssh_public_key
  ssh_allowed_cidrs = var.ssh_allowed_cidrs
}

# Cloudflare DNS — API 도메인 → EC2 Elastic IP (Proxy 모드)
data "cloudflare_zones" "main" {
  account = { id = var.cloudflare_account_id }
  name    = var.domain
}

resource "cloudflare_dns_record" "api" {
  zone_id = data.cloudflare_zones.main.result[0].id
  type    = "A"
  name    = var.api_subdomain
  content = module.ec2.public_ip
  proxied = true
  ttl     = 1
}
