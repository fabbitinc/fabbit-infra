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

# SSH
variable "ssh_public_key" {
  description = "SSH 공개키 내용"
  type        = string
}

variable "ssh_allowed_cidrs" {
  description = "SSH 접근 허용 IP 대역"
  type        = list(string)
  default     = ["0.0.0.0/0"]
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