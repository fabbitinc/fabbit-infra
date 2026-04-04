variable "cloudflare_api_token" {
  description = "Cloudflare API 토큰"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare 계정 ID"
  type        = string
}

variable "fabbit_app_zone_id" {
  description = "fabbit.app Cloudflare zone ID"
  type        = string
  default     = null
}

variable "r2_access_key_id" {
  description = "R2 Access Key ID"
  type        = string
  sensitive   = true
}

variable "r2_secret_access_key" {
  description = "R2 Secret Access Key"
  type        = string
  sensitive   = true
}

variable "r2_cors_allowed_origins" {
  description = "CORS 허용 오리진"
  type        = list(string)
  default     = ["https://*.fabbit.app"]
}

variable "r2_custom_domain" {
  description = "R2 커스텀 도메인"
  type        = string
  default     = "cdn.fabbit.app"
}
