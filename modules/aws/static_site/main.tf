terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.30"
    }
  }
}

locals {
  use_custom_certificate = var.acm_certificate_arn != null && length(var.aliases) > 0
  redirect_enabled       = var.redirect_to_host != null && length(var.redirect_hostnames) > 0
  origin_id              = "s3-${var.bucket_name}"
}

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_control" "this" {
  name                              = "${var.bucket_name}-oac"
  description                       = "${var.bucket_name} S3 접근 제어"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_function" "canonical_redirect" {
  count = local.redirect_enabled ? 1 : 0

  name    = replace("${var.bucket_name}-canonical-redirect", ".", "-")
  runtime = "cloudfront-js-2.0"
  comment = "호스트 canonical redirect"
  publish = true
  code    = <<-EOT
    function buildQuerystring(querystring) {
      var keys = Object.keys(querystring);
      if (keys.length === 0) {
        return "";
      }

      var pairs = [];
      for (var i = 0; i < keys.length; i++) {
        var key = keys[i];
        var item = querystring[key];

        if (item.multiValue) {
          for (var j = 0; j < item.multiValue.length; j++) {
            var multi = item.multiValue[j];
            pairs.push(encodeURIComponent(key) + "=" + encodeURIComponent(multi.value || ""));
          }
          continue;
        }

        pairs.push(encodeURIComponent(key) + "=" + encodeURIComponent(item.value || ""));
      }

      return "?" + pairs.join("&");
    }

    function handler(event) {
      var request = event.request;
      var hostHeader = request.headers.host;
      var host = hostHeader ? hostHeader.value : "";
      var redirectHosts = ${jsonencode(var.redirect_hostnames)};

      if (redirectHosts.indexOf(host) === -1) {
        return request;
      }

      return {
        statusCode: 301,
        statusDescription: "Moved Permanently",
        headers: {
          location: {
            value: "https://${var.redirect_to_host}" + request.uri + buildQuerystring(request.querystring)
          }
        }
      };
    }
  EOT
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = var.enable_ipv6
  comment             = var.comment
  default_root_object = var.default_root_object
  price_class         = var.price_class
  aliases             = local.use_custom_certificate ? var.aliases : []

  origin {
    domain_name              = aws_s3_bucket.this.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
    origin_id                = local.origin_id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.origin_id
    compress         = true

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    dynamic "function_association" {
      for_each = local.redirect_enabled ? [aws_cloudfront_function.canonical_redirect[0]] : []

      content {
        event_type   = "viewer-request"
        function_arn = function_association.value.arn
      }
    }
  }

  dynamic "custom_error_response" {
    for_each = var.single_page_app ? [403, 404] : []

    content {
      error_code            = custom_error_response.value
      response_code         = 200
      response_page_path    = "/index.html"
      error_caching_min_ttl = 0
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = local.use_custom_certificate ? var.acm_certificate_arn : null
    ssl_support_method             = local.use_custom_certificate ? "sni-only" : null
    minimum_protocol_version       = local.use_custom_certificate ? "TLSv1.2_2021" : "TLSv1"
    cloudfront_default_certificate = local.use_custom_certificate ? false : true
  }

  tags = var.tags
}

data "aws_iam_policy_document" "bucket_access" {
  statement {
    sid    = "AllowCloudFrontRead"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.this.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.bucket_access.json
}
