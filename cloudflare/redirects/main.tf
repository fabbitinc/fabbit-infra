terraform {
  required_version = ">= 1.6.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.16"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

locals {
  project = "fabbit"
}

# pages.dev → 커스텀 도메인 Bulk Redirect
resource "cloudflare_list" "pages_redirects" {
  account_id  = var.cloudflare_account_id
  name        = "${local.project}_pages_redirects"
  description = "Pages.dev → 커스텀 도메인 리다이렉트"
  kind        = "redirect"
}

resource "cloudflare_list_item" "redirect_landing" {
  account_id = var.cloudflare_account_id
  list_id    = cloudflare_list.pages_redirects.id

  redirect = {
    source_url            = "https://${local.project}-landing.pages.dev/"
    target_url            = "https://www.${var.domain}"
    status_code           = 301
    include_subdomains    = true
    subpath_matching      = true
    preserve_path_suffix  = true
    preserve_query_string = true
  }
}

resource "cloudflare_list_item" "redirect_web_prod" {
  account_id = var.cloudflare_account_id
  list_id    = cloudflare_list.pages_redirects.id

  redirect = {
    source_url            = "https://${local.project}-web.pages.dev/"
    target_url            = "https://www.${var.domain}"
    status_code           = 301
    include_subdomains    = true
    subpath_matching      = true
    preserve_path_suffix  = true
    preserve_query_string = true
  }
}

resource "cloudflare_ruleset" "pages_redirect_rule" {
  account_id  = var.cloudflare_account_id
  name        = "${local.project}_pages_redirect_rule"
  description = "Pages.dev 리다이렉트 활성화"
  kind        = "root"
  phase       = "http_request_redirect"

  rules = [{
    action = "redirect"
    action_parameters = {
      from_list = {
        name = "${local.project}_pages_redirects"
        key  = "http.request.full_uri"
      }
    }
    expression  = "http.request.full_uri in ${"$"}${local.project}_pages_redirects"
    description = "Pages.dev → 커스텀 도메인"
    enabled     = true
  }]
}
