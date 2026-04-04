variable "aws_region" {
  description = "기본 AWS 리전입니다."
  type        = string
  default     = "ap-northeast-2"
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token입니다."
  type        = string
  sensitive   = true
}

variable "fabbit_app_zone_id" {
  description = "fabbit.app Cloudflare zone ID입니다."
  type        = string
}

variable "fabbitinc_com_zone_id" {
  description = "fabbitinc.com Cloudflare zone ID입니다."
  type        = string
}

variable "landing_bucket_name" {
  description = "landing 정적 자산용 S3 버킷 이름입니다."
  type        = string
  default     = "fabbit-prod-landing-edge"
}

variable "web_bucket_name" {
  description = "web 정적 자산용 S3 버킷 이름입니다."
  type        = string
  default     = "fabbit-prod-web-edge"
}

variable "price_class" {
  description = "CloudFront price class입니다."
  type        = string
  default     = "PriceClass_All"
}

variable "api_origin_ip" {
  description = "api.fabbit.app이 가리킬 OCI 서버 공인 IP입니다."
  type        = string
  default     = "193.122.102.209"
}

variable "tags" {
  description = "공통 태그입니다."
  type        = map(string)
  default     = {}
}

variable "github_actions_role_name" {
  description = "GitHub Actions 배포용 IAM role 이름입니다."
  type        = string
  default     = "github-actions-fabbit-web-deploy"
}

variable "github_actions_allowed_subjects" {
  description = "이 역할을 assume할 수 있는 GitHub OIDC subject 목록입니다."
  type        = list(string)
  default = [
    "repo:fabbitinc/fabbit-web:ref:refs/heads/release",
  ]
}
