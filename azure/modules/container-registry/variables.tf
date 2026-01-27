variable "name" {
  description = "컨테이너 레지스트리 이름 (전역적으로 고유해야 함)"
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

variable "sku" {
  description = "SKU 티어 (Basic, Standard, Premium)"
  type        = string
  default     = "Basic"
}

variable "admin_enabled" {
  description = "관리자 계정 활성화"
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "공용 네트워크 액세스 허용"
  type        = bool
  default     = true
}

variable "tags" {
  description = "리소스 태그"
  type        = map(string)
  default     = {}
}
