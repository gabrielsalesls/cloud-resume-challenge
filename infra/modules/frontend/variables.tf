variable "s3_website_bucket_name" {
  description = "Name of the S3 Bucket"
  type        = string
  default     = "gabrielsalesls-static-website-code-challenge"
}

variable "app_path" {
  description = "Path to the Website files"
  type        = string
  default     = "../frontend/website"
}

variable "domain_name" {
  description = "Domain name"
  type        = string
  default     = "gabrielsales.dev"
}

variable "api_gateway_endpoint" {
  description = "API gateway endpoint to get visitors"
  type        = string
}