terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.16"
    }
  }
}

# Cloudflare Pages 프로젝트 (Direct Upload 방식)
# GitHub Actions에서 빌드 후 wrangler pages deploy로 배포
resource "cloudflare_pages_project" "this" {
  account_id        = var.account_id
  name              = var.project_name
  production_branch = var.production_branch

  # source 블록 없음 - Git 연동 사용 안 함
  # build_config 블록 없음 - Cloudflare에서 빌드 안 함

  deployment_configs = {
    production = {
      compatibility_date    = var.compatibility_date
      environment_variables = var.production_env_vars
    }

    preview = {
      compatibility_date    = var.compatibility_date
      environment_variables = var.preview_env_vars
    }
  }
}
