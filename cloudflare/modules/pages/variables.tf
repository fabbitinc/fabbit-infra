variable "account_id" {
  description = "Cloudflare 계정 ID"
  type        = string
}

variable "project_name" {
  description = "Pages 프로젝트 이름"
  type        = string
}

variable "production_branch" {
  description = "프로덕션 브랜치"
  type        = string
  default     = "main"
}

variable "compatibility_date" {
  description = "Workers 호환성 날짜"
  type        = string
  default     = "2024-01-01"
}

variable "production_env_vars" {
  description = "프로덕션 환경 변수"
  type        = map(string)
  default     = {}
}

variable "preview_env_vars" {
  description = "프리뷰 환경 변수"
  type        = map(string)
  default     = {}
}
