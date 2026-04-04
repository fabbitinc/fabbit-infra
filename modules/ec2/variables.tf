variable "environment" {
  description = "환경 이름 (dev, prod)"
  type        = string
}

variable "project" {
  description = "프로젝트 이름"
  type        = string
}

variable "instance_type" {
  description = "EC2 인스턴스 타입 (dev: t3.small, prod: t3.medium)"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH 공개키 내용"
  type        = string
}

variable "ssh_allowed_cidrs" {
  description = "SSH 접근 허용 IP 대역"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "iam_instance_profile_name" {
  description = "IAM Instance Profile 이름 (없으면 미연결)"
  type        = string
  default     = null
}
