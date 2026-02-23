# 환경 설정
variable "environment" {
  description = "환경 이름 (dev, prod)"
  type        = string
}

variable "instance_type" {
  description = "EC2 인스턴스 타입"
  type        = string
}

variable "api_subdomain" {
  description = "API 서브도메인 (dev: api-dev, prod: api)"
  type        = string
}

variable "domain" {
  description = "Cloudflare Zone 도메인 (예: fabbitinc.com)"
  type        = string
  default     = "fabbitinc.com"
}

# 알림
variable "alert_email" {
  description = "비용 알림 수신 이메일"
  type        = string
}

# SSH
variable "ssh_public_key" {
  description = "SSH 공개키 내용"
  type        = string
}

variable "ssh_allowed_cidrs" {
  description = "SSH 접근 허용 IP 대역"
  type        = list(string)
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

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID (EC2 커스텀 도메인용)"
  type        = string
  default     = null
}