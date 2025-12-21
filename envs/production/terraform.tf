locals {
  tfstate_bucket_name = "tfstate-31115663950920251219185056487700000001"
  root_domain         = "saas.vflopes.com"
}

terraform {
  backend "s3" {
    bucket       = "tfstate-31115663950920251219185056487700000001"
    key          = "saas-infrastructure/production.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }


  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.27.0"
    }
  }
}

provider "aws" {}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

provider "aws" {
  alias  = "aws_us_east_1"
  region = "us-east-1"
}

data "aws_s3_bucket" "tfstate" {
  bucket = local.tfstate_bucket_name
}
