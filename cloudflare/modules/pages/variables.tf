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

