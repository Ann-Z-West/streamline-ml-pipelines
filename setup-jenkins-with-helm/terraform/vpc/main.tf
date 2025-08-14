terraform {

  backend "s3" {
    bucket  = "devops-tfstate"
    encrypt = true
    key     = "state/vpc.tfstate"

    dynamodb_table = "devops-terraform"
    region         = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      DL        = "microscopy.app@gmail.com"
      OWNER     = var.owner
      Terraform = "true"
    }
  }
}

# This allows for later 'data.aws_region.current.name' use to obtain the active
# region (e.g. us-east-1) without having to use a variable or update the region
# everywhere.
data "aws_region" "current" {}

data "aws_vpcs" "devops" {
  filter {
    name   = "tag:Name"
    values = [join("-", ["devops", data.aws_region.current.name])]
  }
}
