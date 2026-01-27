# 로컬 백엔드 (초기 개발용)
# 프로덕션 환경에서는 Azure Blob Storage 백엔드 사용 권장

# terraform {
#   backend "azurerm" {
#     resource_group_name  = "rg-fabbit-tfstate"
#     storage_account_name = "stfabbittfstate"
#     container_name       = "tfstate"
#     key                  = "prod.terraform.tfstate"
#   }
# }
