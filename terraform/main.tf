terraform {
  required_version = ">= 0.11.12"

  backend "s3" {
    role_arn = "arn:aws:iam::269807742353:role/developer"

    bucket         = "wellcomecollection-reporting-infra"
    key            = "terraform/reporting.tfstate"
    dynamodb_table = "terraform-locktable"
    region         = "eu-west-1"
  }
}

provider "aws" {
  version = "~> 2.9"
  region  = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::269807742353:role/developer"
  }
}

provider "aws" {
  alias   = "aws_platform"
  version = "~> 2.9"
  region  = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::760097843905:role/developer"
  }
}

provider "template" {
  version = "~> 2.1"
}

module "sierra_varFields_lambda" {
  source = "modules/reporting_lambda"

  providers = {
    aws_platform = "aws.aws_platform"
  }
}
