variable "name" {
  description = "Container App 이름"
  type        = string
}

variable "resource_group_name" {
  description = "리소스 그룹 이름"
  type        = string
}

variable "location" {
  description = "Azure 리전"
  type        = string
}

variable "log_retention_days" {
  description = "로그 보존 기간 (일)"
  type        = number
  default     = 30
}

variable "revision_mode" {
  description = "리비전 모드 (Single, Multiple)"
  type        = string
  default     = "Single"
}

variable "container_name" {
  description = "컨테이너 이름"
  type        = string
}

variable "container_image" {
  description = "컨테이너 이미지"
  type        = string
}

variable "cpu" {
  description = "CPU 코어 수"
  type        = number
  default     = 0.5
}

variable "memory" {
  description = "메모리 크기 (예: 1Gi)"
  type        = string
  default     = "1Gi"
}

variable "min_replicas" {
  description = "최소 레플리카 수"
  type        = number
  default     = 0
}

variable "max_replicas" {
  description = "최대 레플리카 수"
  type        = number
  default     = 3
}

variable "external_enabled" {
  description = "외부 Ingress 활성화"
  type        = bool
  default     = true
}

variable "target_port" {
  description = "타겟 포트"
  type        = number
  default     = 8000
}

variable "environment_variables" {
  description = "환경 변수 맵"
  type = map(object({
    value       = optional(string)
    secret_name = optional(string)
  }))
  default = {}
}

variable "secrets" {
  description = "시크릿 맵"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "container_registry_server" {
  description = "컨테이너 레지스트리 서버"
  type        = string
  default     = null
}

variable "container_registry_username" {
  description = "컨테이너 레지스트리 사용자 이름"
  type        = string
  default     = null
}

variable "container_registry_password_secret_name" {
  description = "컨테이너 레지스트리 비밀번호 시크릿 이름"
  type        = string
  default     = null
}

variable "tags" {
  description = "리소스 태그"
  type        = map(string)
  default     = {}
}
