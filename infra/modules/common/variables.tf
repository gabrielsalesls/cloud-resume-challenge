variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "cloud resume challenge"
    Owner       = "Gabriel Sales"
  }
}

output "tags" {
  value = var.tags
}