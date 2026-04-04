terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 6.30"
      configuration_aliases = [aws.us_east_1]
    }
  }
}

resource "aws_acm_certificate" "this" {
  provider = aws.us_east_1

  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}
