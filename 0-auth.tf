terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.22.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      TeamMember   = "Prof Cloud"
      ManagedBy = "Terraform"
      Environment = "Dev"
      Location = "London"
    }
  }
}