terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 0.14"
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = local.common_tags
  }
}