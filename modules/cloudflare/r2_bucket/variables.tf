variable "account_id" {
  description = "Cloudflare 계정 ID"
  type        = string
}

variable "bucket_name" {
  description = "R2 버킷 이름"
  type        = string
}

variable "location" {
  description = "R2 버킷 위치"
  type        = string
  default     = "APAC"
}

variable "cors_allowed_origins" {
  description = "CORS 허용 오리진"
  type        = list(string)
  default     = ["*"]
}

variable "cors_allowed_methods" {
  description = "CORS 허용 메서드"
  type        = list(string)
  default     = ["GET", "PUT", "POST", "DELETE", "HEAD"]
}

variable "cors_allowed_headers" {
  description = "CORS 허용 헤더"
  type        = list(string)
  default     = ["*"]
}

variable "cors_expose_headers" {
  description = "CORS 노출 헤더"
  type        = list(string)
  default     = ["ETag", "Content-Length", "Content-Type"]
}

variable "cors_max_age_seconds" {
  description = "CORS preflight 캐시 시간"
  type        = number
  default     = 3600
}

variable "zone_id" {
  description = "커스텀 도메인용 Zone ID"
  type        = string
  default     = null
}

variable "custom_domain" {
  description = "R2 퍼블릭 액세스 커스텀 도메인"
  type        = string
  default     = null
}
