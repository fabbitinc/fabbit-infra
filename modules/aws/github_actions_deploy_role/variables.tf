variable "role_name" {
  description = "GitHub Actions가 assume할 IAM role 이름입니다."
  type        = string
}

variable "allowed_subjects" {
  description = "허용할 GitHub OIDC subject 목록입니다."
  type        = list(string)
}

variable "bucket_arns" {
  description = "배포 대상 S3 버킷 ARN 목록입니다."
  type        = list(string)
}

variable "tags" {
  description = "공통 태그입니다."
  type        = map(string)
  default     = {}
}
