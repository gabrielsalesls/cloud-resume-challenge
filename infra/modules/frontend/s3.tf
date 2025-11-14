module "common" {
  source = "../common"
}

# Bucket S3
resource "aws_s3_bucket" "website_bucket" {
  bucket = var.s3_website_bucket_name

  tags = merge(
    module.common.tags,
    {
      description = "Static Website Bucket"
    }
  )
}

# Upload dos arquivos
resource "aws_s3_object" "website_files" {
  for_each     = fileset(var.app_path, "**/*")
  key          = each.key
  bucket       = aws_s3_bucket.website_bucket.id
  source       = "${var.app_path}/${each.value}"
  content_type = lookup(local.mime_types, regex("\\.[^.]+$", each.value), "application/octet-stream")
}

# Bloquear TODO acesso público
resource "aws_s3_bucket_public_access_block" "static_website_access_block" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}

# Bucket Policy - permite APENAS CloudFront
data "aws_iam_policy_document" "origin_bucket_policy" {
  depends_on = [aws_cloudfront_distribution.website_s3_distribution]

  statement {
    sid    = "AllowCloudFrontServicePrincipalReadWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = ["${aws_s3_bucket.website_bucket.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.website_s3_distribution.arn]
    }
  }
}

# Adiciona o bucket policy criado anteriormente 
resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = data.aws_iam_policy_document.origin_bucket_policy.json
}

# Origin Access Control (método mais moderno que OAI)
resource "aws_cloudfront_origin_access_control" "website_oac" {
  depends_on                        = [aws_s3_bucket.website_bucket]
  name                              = "${var.s3_website_bucket_name}-oac"
  description                       = "OAC for ${var.s3_website_bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "website_s3_distribution" {

depends_on = [aws_acm_certificate_validation.this]
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  comment             = "CloudFront distribution for ${var.s3_website_bucket_name}"
  price_class         = "PriceClass_100"

  aliases = [
    var.domain_name,
    "www.${var.domain_name}"
  ]

  origin {
    domain_name              = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id                = "S3-${var.s3_website_bucket_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.website_oac.id
  }

  default_cache_behavior {
    target_origin_id = "S3-${var.s3_website_bucket_name}"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  # Página de erro personalizada (opcional)
  custom_error_response {
    error_code         = 403
    response_code      = 404
    response_page_path = "/error.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 404
    response_page_path = "/error.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Configuração do certificado SSL customizado
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.this.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = module.common.tags
}