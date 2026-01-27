# 로컬 백엔드 (초기 개발용)
# 추후 Cloudflare R2 또는 다른 원격 백엔드로 이전 권장

# terraform {
#   backend "s3" {
#     bucket                      = "fabbit-tfstate"
#     key                         = "cloudflare/dev.terraform.tfstate"
#     region                      = "auto"
#     skip_credentials_validation = true
#     skip_metadata_api_check     = true
#     skip_region_validation      = true
#     skip_requesting_account_id  = true
#     use_path_style              = true
#     endpoints = {
#       s3 = "https://<account-id>.r2.cloudflarestorage.com"
#     }
#   }
# }
