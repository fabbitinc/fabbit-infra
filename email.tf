# SES — 트랜잭션 이메일 발송 (ses_enabled = true일 때만)

# SES 발송 권한
resource "aws_iam_role_policy" "ses_send" {
  count = var.ses_enabled ? 1 : 0
  name  = "${local.project}-${var.environment}-ses-send"
  role  = aws_iam_role.ec2.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ses:SendEmail", "ses:SendRawEmail"]
      Resource = "*"
    }]
  })
}

# SES 도메인 인증
resource "aws_sesv2_email_identity" "domain" {
  count          = var.ses_enabled ? 1 : 0
  email_identity = var.landing_domain
}

# DKIM CNAME 레코드 (Cloudflare) — 3개
resource "cloudflare_dns_record" "ses_dkim" {
  count   = var.ses_enabled ? 3 : 0
  zone_id = var.landing_zone_id
  type    = "CNAME"
  name    = "${aws_sesv2_email_identity.domain[0].dkim_signing_attributes[0].tokens[count.index]}._domainkey.${var.landing_domain}"
  content = "${aws_sesv2_email_identity.domain[0].dkim_signing_attributes[0].tokens[count.index]}.dkim.amazonses.com"
  proxied = false
  ttl     = 1
}

# MAIL FROM 도메인
resource "aws_sesv2_email_identity_mail_from_attributes" "domain" {
  count            = var.ses_enabled ? 1 : 0
  email_identity   = aws_sesv2_email_identity.domain[0].email_identity
  mail_from_domain = "mail.${var.landing_domain}"
}

resource "cloudflare_dns_record" "ses_mail_from_mx" {
  count    = var.ses_enabled ? 1 : 0
  zone_id  = var.landing_zone_id
  type     = "MX"
  name     = "mail.${var.landing_domain}"
  content  = "feedback-smtp.ap-northeast-2.amazonses.com"
  priority = 10
  proxied  = false
  ttl      = 1
}

resource "cloudflare_dns_record" "ses_mail_from_spf" {
  count   = var.ses_enabled ? 1 : 0
  zone_id = var.landing_zone_id
  type    = "TXT"
  name    = "mail.${var.landing_domain}"
  content = "v=spf1 include:amazonses.com ~all"
  proxied = false
  ttl     = 1
}

# DMARC TXT 레코드 — 모니터링 모드(p=none), 추후 quarantine/reject로 강화
resource "cloudflare_dns_record" "dmarc" {
  count   = var.ses_enabled ? 1 : 0
  zone_id = var.landing_zone_id
  type    = "TXT"
  name    = "_dmarc.${var.landing_domain}"
  content = "v=DMARC1; p=none;"
  proxied = false
  ttl     = 1
}
