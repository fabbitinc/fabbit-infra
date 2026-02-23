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

# 비용 알림 — Free Tier 초과 시 이메일 알림
resource "aws_budgets_budget" "zero_spend" {
  name         = "fabbit-${var.environment}-zero-spend"
  budget_type  = "COST"
  limit_amount = "0.01"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }
}

# GitHub Actions OIDC — Access Key 없이 AWS 인증
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["ffffffffffffffffffffffffffffffffffffffff"]
}

resource "aws_iam_role" "github_actions" {
  name = "${local.project}-${var.environment}-github-actions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/*:*"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "github_actions_deploy" {
  name = "${local.project}-${var.environment}-deploy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupIngress",
      ]
      Resource = "*"
    }]
  })
}

# Cloudflare SSL — Flexible 모드 (Cloudflare → EC2는 HTTP)
resource "cloudflare_zone_setting" "ssl" {
  zone_id    = var.cloudflare_zone_id
  setting_id = "ssl"
  value      = "flexible"
}

# Cloudflare DNS — API 도메인 → EC2 Elastic IP (Proxy 모드)
resource "cloudflare_dns_record" "api" {
  zone_id = var.cloudflare_zone_id
  type    = "A"
  name    = var.api_subdomain
  content = module.ec2.public_ip
  proxied = true
  ttl     = 1
}
