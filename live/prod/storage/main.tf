module "r2_storage" {
  source = "../../../modules/cloudflare/r2_bucket"

  providers = {
    aws.r2 = aws.r2
  }

  account_id           = var.cloudflare_account_id
  bucket_name          = "${local.project}-${local.environment}"
  cors_allowed_origins = var.r2_cors_allowed_origins
}
