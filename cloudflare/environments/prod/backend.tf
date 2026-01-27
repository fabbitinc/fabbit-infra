# 로컬 백엔드 (초기 개발용)
# 프로덕션 환경에서는 원격 백엔드 사용 권장

# terraform {
#   backend "s3" {
#     bucket                      = "fabbit-tfstate"
#     key                         = "cloudflare/prod.terraform.tfstate"
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
