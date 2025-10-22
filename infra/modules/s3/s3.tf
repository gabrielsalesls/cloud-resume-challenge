module "common" {
  source = "../common"
}

resource "aws_s3_bucket" "website_bucket" {
  bucket = "gabrielsalesls-static-website-code-challenge"

  tags = merge(
    module.common.tags,
    {
      description = "Static Website Bucket"
    }
  )
}

resource "aws_s3_object" "website_files" {
  for_each = fileset(var.app_path, "**/*")
  key      = each.key
  bucket   = aws_s3_bucket.website_bucket.id
  source   = "${var.app_path}/${each.value}"
  content_type = lookup(local.mime_types, regex("\\.[^.]+$", each.value), "application/octet-stream")
}
