provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = var.credentials
  profile                  = var.profile

  default_tags {
    tags = {
      Terraform = "true"
      Team      = "devops"
      Owner     = var.owner
    }
  }
}

# This allows for later 'data.aws_region.current.name' to obtain the active region (e.g. us-east-1)
# without having to use a variable or update the region everywhere.
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

terraform {
  backend "s3" {
    bucket  = "devops-tfstate"
    encrypt = true
    key     = "state/terraform-bootstrap.tfstate"

    dynamodb_table = "devops-terraform"
    region         = "us-east-1"
  }
}