variable "cloudflare_api_token" {
  description = "Cloudflare API 토큰"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare 계정 ID"
  type        = string
}

variable "domain" {
  description = "Cloudflare Zone 도메인 (예: fabbitinc.com)"
  type        = string
}
