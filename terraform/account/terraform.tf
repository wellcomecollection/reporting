terraform {
  required_version = ">= 0.11.12"

  backend "s3" {
    bucket         = "wellcomecollection-reporting-infra"
    key            = "terraform/reporting-account.tfstate"
    dynamodb_table = "terraform-locktable"
    region         = "eu-west-1"
  }
}

provider "aws" {
  version = "~> 2.9"
  region  = "eu-west-1"
}

provider "template" {
  version = "~> 2.1"
}
