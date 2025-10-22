resource "aws_s3_bucket" "backend" {
  bucket = "gabrielsalesls-terraform-state-backend-cloud-challenge"
  force_destroy = true

  tags = {
    Description = "Stores terraform remote state files"
    ManagedBy   = "Terraform"
    Owner       = "Gabriel Sales"
  }
}

resource "aws_s3_bucket_versioning" "backend_versioning" {
  bucket = aws_s3_bucket.backend.id
  versioning_configuration {
    status = "Enabled"
  }
}