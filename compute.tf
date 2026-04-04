# IAM Role + Instance Profile — EC2가 AWS 서비스(SES 등)를 호출할 수 있도록
resource "aws_iam_role" "ec2" {
  name = "${local.project}-${var.environment}-ec2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${local.project}-${var.environment}-ec2"
  role = aws_iam_role.ec2.name
}

# EC2 인스턴스 (Docker Compose로 API + DB 운영)
module "ec2" {
  source = "./modules/ec2"

  environment               = var.environment
  project                   = local.project
  instance_type             = var.instance_type
  ssh_public_key            = var.ssh_public_key
  ssh_allowed_cidrs         = var.ssh_allowed_cidrs
  iam_instance_profile_name = aws_iam_instance_profile.ec2.name
}

# Cloudflare SSL — Flexible 모드 (Cloudflare → EC2는 HTTP)
resource "cloudflare_zone_setting" "ssl" {
  zone_id    = var.app_zone_id
  setting_id = "ssl"
  value      = "flexible"
}

# Cloudflare DNS — API 도메인 → EC2 Elastic IP (Proxy 모드)
resource "cloudflare_dns_record" "api" {
  zone_id = var.app_zone_id
  type    = "A"
  name    = var.api_subdomain
  content = module.ec2.public_ip
  proxied = true
  ttl     = 1
}
