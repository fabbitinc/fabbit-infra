terraform {
  required_version = ">= 1.6.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

locals {
  project = "fabbit"
}

# Cloudflare Pages - 랜딩 페이지
module "pages_landing" {
  source = "../../modules/pages"

  account_id        = var.cloudflare_account_id
  project_name      = "${local.project}-landing"
  production_branch = "main"

  production_env_vars = {}
  preview_env_vars    = {}
}
