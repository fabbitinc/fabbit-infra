locals {
  landing_certificate_validation_records = {
    for domain_name, record in module.landing_certificate.validation_records :
    domain_name => {
      name  = trimsuffix(record.name, ".")
      type  = record.type
      value = trimsuffix(record.value, ".")
    }
  }

  web_certificate_validation_records = contains(keys(module.web_certificate.validation_records), "*.fabbit.app") ? {
    "*.fabbit.app" = {
      name  = trimsuffix(module.web_certificate.validation_records["*.fabbit.app"].name, ".")
      type  = module.web_certificate.validation_records["*.fabbit.app"].type
      value = trimsuffix(module.web_certificate.validation_records["*.fabbit.app"].value, ".")
    }
    } : {
    for domain_name, record in module.web_certificate.validation_records :
    domain_name => {
      name  = trimsuffix(record.name, ".")
      type  = record.type
      value = trimsuffix(record.value, ".")
    }
  }
}

module "landing_certificate" {
  source = "../../../modules/aws/acm_certificate"

  providers = {
    aws.us_east_1 = aws.us_east_1
  }

  domain_name               = "fabbitinc.com"
  subject_alternative_names = ["www.fabbitinc.com"]
  tags                      = merge(local.common_tags, { Service = "landing" })
}

resource "cloudflare_dns_record" "landing_certificate_validation" {
  for_each = local.landing_certificate_validation_records

  zone_id = var.fabbitinc_com_zone_id
  name    = each.value.name
  content = each.value.value
  type    = each.value.type
  ttl     = 1
  proxied = false
}

resource "aws_acm_certificate_validation" "landing" {
  provider = aws.us_east_1

  certificate_arn         = module.landing_certificate.certificate_arn
  validation_record_fqdns = [for record in values(local.landing_certificate_validation_records) : record.name]

  depends_on = [cloudflare_dns_record.landing_certificate_validation]
}

module "web_certificate" {
  source = "../../../modules/aws/acm_certificate"

  providers = {
    aws.us_east_1 = aws.us_east_1
  }

  domain_name               = "fabbit.app"
  subject_alternative_names = ["*.fabbit.app"]
  tags                      = merge(local.common_tags, { Service = "web" })
}

resource "cloudflare_dns_record" "web_certificate_validation" {
  for_each = local.web_certificate_validation_records

  zone_id = var.fabbit_app_zone_id
  name    = each.value.name
  content = each.value.value
  type    = each.value.type
  ttl     = 1
  proxied = false
}

resource "aws_acm_certificate_validation" "web" {
  provider = aws.us_east_1

  certificate_arn         = module.web_certificate.certificate_arn
  validation_record_fqdns = [for record in values(local.web_certificate_validation_records) : record.name]

  depends_on = [cloudflare_dns_record.web_certificate_validation]
}

module "landing" {
  source = "../../../modules/aws/static_site"

  bucket_name         = var.landing_bucket_name
  aliases             = ["fabbitinc.com", "www.fabbitinc.com"]
  acm_certificate_arn = aws_acm_certificate_validation.landing.certificate_arn
  single_page_app     = true
  comment             = "Fabbit prod landing edge"
  price_class         = var.price_class
  tags                = merge(local.common_tags, { Service = "landing" })
}

module "web" {
  source = "../../../modules/aws/static_site"

  bucket_name         = var.web_bucket_name
  aliases             = ["fabbit.app", "*.fabbit.app"]
  acm_certificate_arn = aws_acm_certificate_validation.web.certificate_arn
  single_page_app     = true
  comment             = "Fabbit prod web edge"
  price_class         = var.price_class
  tags                = merge(local.common_tags, { Service = "web" })
}

module "github_actions_deploy_role" {
  source = "../../../modules/aws/github_actions_deploy_role"

  role_name        = var.github_actions_role_name
  allowed_subjects = var.github_actions_allowed_subjects
  bucket_arns = [
    module.landing.bucket_arn,
    module.web.bucket_arn,
  ]
  tags = merge(local.common_tags, { Service = "edge-deploy" })
}

resource "cloudflare_dns_record" "landing_apex" {
  zone_id = var.fabbitinc_com_zone_id
  name    = "fabbitinc.com"
  content = module.landing.distribution_domain_name
  type    = "CNAME"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "landing_www" {
  zone_id = var.fabbitinc_com_zone_id
  name    = "www"
  content = module.landing.distribution_domain_name
  type    = "CNAME"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "web_apex" {
  zone_id = var.fabbit_app_zone_id
  name    = "fabbit.app"
  content = module.web.distribution_domain_name
  type    = "CNAME"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "web_wildcard" {
  zone_id = var.fabbit_app_zone_id
  name    = "*"
  content = module.web.distribution_domain_name
  type    = "CNAME"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "api_origin" {
  zone_id = var.fabbit_app_zone_id
  name    = "api"
  content = var.api_origin_ip
  type    = "A"
  ttl     = 1
  proxied = false
}
