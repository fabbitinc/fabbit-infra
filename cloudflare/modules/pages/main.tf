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

  # 환경 변수는 wrangler pages deploy 시 설정
  # GitHub Actions에서 빌드 시 VITE_API_URL 등 주입

  # Cloudflare provider v5 버그: Pages 업데이트 시 API 에러
  # https://github.com/cloudflare/terraform-provider-cloudflare/issues/5146
  lifecycle {
    ignore_changes = all
  }
}
