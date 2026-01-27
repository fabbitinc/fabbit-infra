variable "name" {
  description = "Key Vault 이름 (전역적으로 고유해야 함)"
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

variable "sku_name" {
  description = "SKU 이름 (standard, premium)"
  type        = string
  default     = "standard"
}

variable "soft_delete_retention_days" {
  description = "소프트 삭제 보존 기간 (일)"
  type        = number
  default     = 7
}

variable "purge_protection_enabled" {
  description = "퍼지 보호 활성화"
  type        = bool
  default     = false
}

variable "enable_rbac_authorization" {
  description = "RBAC 인증 활성화"
  type        = bool
  default     = false
}

variable "default_network_action" {
  description = "기본 네트워크 액션 (Allow, Deny)"
  type        = string
  default     = "Allow"
}

variable "secrets" {
  description = "저장할 시크릿 맵"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "tags" {
  description = "리소스 태그"
  type        = map(string)
  default     = {}
}
