# 환경 설정
variable "environment" {
  description = "환경 이름 (dev, prod)"
  type        = string
}

# Cloudflare 인증
variable "cloudflare_api_token" {
  description = "Cloudflare API 토큰"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare 계정 ID"
  type        = string
}

# R2 인증
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

# R2 설정
variable "r2_cors_allowed_origins" {
  description = "CORS 허용 오리진"
  type        = list(string)
  default     = []
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID (R2 커스텀 도메인용)"
  type        = string
  default     = null
}

variable "r2_custom_domain" {
  description = "R2 퍼블릭 액세스 커스텀 도메인 (예: cdn.fabbitinc.com)"
  type        = string
  default     = null
}
