terraform {
  required_version = ">= 1.13.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "gabrielsalesls-terraform-state-backend-cloud-challenge"
    key     = "cloud-challenge/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}