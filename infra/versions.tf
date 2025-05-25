terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Using a specific major version for stability
    }
  }
}

provider "aws" {
  region = var.aws_region
}
