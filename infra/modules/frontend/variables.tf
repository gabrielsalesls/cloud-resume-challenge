variable "s3_website_bucket_name" {
  description = "Name of the S3 Bucket"
  type        = string
  default = "gabrielsalesls-static-website-code-challenge"
}

variable "app_path" {
  description = "Path to the Website files"
  type        = string
  default     = "../website"
}