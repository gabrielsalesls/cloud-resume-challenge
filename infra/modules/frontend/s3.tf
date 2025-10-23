module "common" {
  source = "../common"
}

resource "aws_s3_bucket" "website_bucket" {
  bucket = var.s3_website_bucket_name

  tags = merge(
    module.common.tags,
    {
      description = "Static Website Bucket"
    }
  )
}

resource "aws_s3_object" "website_files" {
  for_each     = fileset(var.app_path, "**/*")
  key          = each.key
  bucket       = aws_s3_bucket.website_bucket.id
  source       = "${var.app_path}/${each.value}"
  content_type = lookup(local.mime_types, regex("\\.[^.]+$", each.value), "application/octet-stream")
}

resource "aws_s3_bucket_website_configuration" "website_configuration" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "static_website_access_block" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false

}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id
       depends_on = [aws_s3_bucket_public_access_block.static_website_access_block]


  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject"
        ]
        Resource = [
          "${aws_s3_bucket.website_bucket.arn}/*"
        ]
      }
    ]
  })
}