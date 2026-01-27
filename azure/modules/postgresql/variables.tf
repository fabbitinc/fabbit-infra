variable "name" {
  description = "PostgreSQL 서버 이름"
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

variable "postgresql_version" {
  description = "PostgreSQL 버전"
  type        = string
  default     = "16"
}

variable "delegated_subnet_id" {
  description = "위임된 서브넷 ID (VNet 통합시 필요)"
  type        = string
  default     = null
}

variable "private_dns_zone_id" {
  description = "프라이빗 DNS 존 ID"
  type        = string
  default     = null
}

variable "public_network_access_enabled" {
  description = "공용 네트워크 액세스 허용 여부"
  type        = bool
  default     = true
}

variable "administrator_login" {
  description = "관리자 로그인 이름"
  type        = string
}

variable "administrator_password" {
  description = "관리자 비밀번호"
  type        = string
  sensitive   = true
}

variable "storage_mb" {
  description = "스토리지 크기 (MB)"
  type        = number
  default     = 32768
}

variable "storage_tier" {
  description = "스토리지 티어"
  type        = string
  default     = "P4"
}

variable "sku_name" {
  description = "SKU 이름 (예: B_Standard_B1ms)"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "zone" {
  description = "가용성 영역"
  type        = string
  default     = null
}

variable "backup_retention_days" {
  description = "백업 보존 기간 (일)"
  type        = number
  default     = 7
}

variable "geo_redundant_backup_enabled" {
  description = "지리적 중복 백업 활성화"
  type        = bool
  default     = false
}

variable "database_name" {
  description = "데이터베이스 이름"
  type        = string
}

variable "allow_azure_services" {
  description = "Azure 서비스에서 접근 허용"
  type        = bool
  default     = true
}

variable "allowed_ip_ranges" {
  description = "허용된 IP 범위 맵"
  type = map(object({
    start_ip = string
    end_ip   = string
  }))
  default = {}
}

variable "tags" {
  description = "리소스 태그"
  type        = map(string)
  default     = {}
}
