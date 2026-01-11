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

resource "aws_s3_object" "main_js" {
  bucket       = aws_s3_bucket.website_bucket.id
  key          = "main.js"
  content_type = "application/javascript"

  content = templatefile(
    "../frontend/template/main.js",
    {
      api_url = var.api_gateway_endpoint
    }
  )
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