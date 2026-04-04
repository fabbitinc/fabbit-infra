# 환경 설정
variable "environment" {
  description = "환경 이름 (dev, prod)"
  type        = string
}

variable "app_domain" {
  description = "앱 도메인 (API, R2, Worker)"
  type        = string
  default     = "fabbit.app"
}

variable "landing_domain" {
  description = "랜딩/회사 도메인 (랜딩 페이지, SES 이메일)"
  type        = string
  default     = "fabbitinc.com"
}

# EC2
variable "instance_type" {
  description = "EC2 인스턴스 타입"
  type        = string
}

variable "api_subdomain" {
  description = "API 서브도메인 (dev: api-dev, prod: api)"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH 공개키 내용"
  type        = string
  sensitive   = true
}

variable "ssh_allowed_cidrs" {
  description = "SSH 접근 허용 IP 대역"
  type        = list(string)
}

# 알림
variable "alert_email" {
  description = "비용 알림 수신 이메일"
  type        = string
}

# GitHub
variable "github_org" {
  description = "GitHub Organization 이름"
  type        = string
  default     = "fabbitinc"
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

variable "app_zone_id" {
  description = "Cloudflare Zone ID (fabbit.app)"
  type        = string
}

variable "landing_zone_id" {
  description = "Cloudflare Zone ID (fabbitinc.com) — SES DNS 용"
  type        = string
  default     = null
}

# R2
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
  default     = []
}

variable "r2_custom_domain" {
  description = "R2 퍼블릭 액세스 커스텀 도메인 (예: cdn.fabbitinc.com)"
  type        = string
  default     = null
}

# Worker
variable "pages_origin" {
  description = "Pages 프록시 오리진 URL (예: https://fabbit-web.pages.dev)"
  type        = string
}

# SES
variable "ses_enabled" {
  description = "SES 도메인 인증 활성화 여부"
  type        = bool
  default     = false
}
