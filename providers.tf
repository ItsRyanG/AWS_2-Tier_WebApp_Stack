terraform {
  required_version = ">= 1.8.0"

  backend "s3" {
    bucket       = "terraform-state-agffa"
    key          = "envs/dev/fortis-terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

}