terraform {
  required_providers {
    aws = {
      // I would like to run the instance in ap-east-3
      version = "~> 3.27"
    }
  }
}
provider "aws" {
  region                  = var.aws_region
  shared_credentials_file = var.shared_credentials_file
  profile                 = var.profile
}

