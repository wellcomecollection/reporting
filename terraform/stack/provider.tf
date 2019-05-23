provider "aws" {
  version = "~> 2.9"
  region  = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::269807742353:role/developer"
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "us_east_1"

  assume_role {
    role_arn = "arn:aws:iam::269807742353:role/developer"
  }
}

provider "template" {
  version = "~> 2.1"
}
