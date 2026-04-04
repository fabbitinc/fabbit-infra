variable "bucket_name" {
  description = "정적 파일을 저장할 S3 버킷 이름입니다."
  type        = string
}

variable "aliases" {
  description = "CloudFront Alternate Domain Names 목록입니다."
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "CloudFront에 연결할 ACM 인증서 ARN입니다."
  type        = string
  default     = null
}

variable "default_root_object" {
  description = "기본 루트 오브젝트입니다."
  type        = string
  default     = "index.html"
}

variable "single_page_app" {
  description = "SPA fallback을 사용할지 여부입니다."
  type        = bool
  default     = true
}

variable "comment" {
  description = "CloudFront distribution 설명입니다."
  type        = string
  default     = null
}

variable "price_class" {
  description = "CloudFront price class입니다."
  type        = string
  default     = "PriceClass_100"
}

variable "enable_ipv6" {
  description = "IPv6 활성화 여부입니다."
  type        = bool
  default     = true
}

variable "tags" {
  description = "공통 태그입니다."
  type        = map(string)
  default     = {}
}
