provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

locals {
  environment = "prod"
  project     = "fabbit"

  common_tags = merge(
    {
      Project     = local.project
      Environment = local.environment
      ManagedBy   = "OpenTofu"
    },
    var.tags
  )
}
