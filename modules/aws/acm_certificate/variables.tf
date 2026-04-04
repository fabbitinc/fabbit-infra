variable "domain_name" {
  description = "ACM 기본 도메인입니다."
  type        = string
}

variable "subject_alternative_names" {
  description = "ACM 추가 도메인 목록입니다."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "공통 태그입니다."
  type        = map(string)
  default     = {}
}
