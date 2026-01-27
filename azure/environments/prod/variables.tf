variable "location" {
  description = "Azure 리전"
  type        = string
  default     = "koreacentral"
}

variable "postgresql_admin_login" {
  description = "PostgreSQL 관리자 로그인"
  type        = string
  default     = "fabbitadmin"
}

variable "postgresql_password" {
  description = "PostgreSQL 관리자 비밀번호"
  type        = string
  sensitive   = true
}

variable "openai_api_key" {
  description = "OpenAI API 키"
  type        = string
  sensitive   = true
}

# Cloudflare R2 연동 변수
variable "r2_endpoint_url" {
  description = "R2 S3 호환 엔드포인트 URL"
  type        = string
}

variable "r2_bucket_name" {
  description = "R2 버킷 이름"
  type        = string
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
