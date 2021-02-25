provider "aws" {
  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::269807742353:role/reporting-developer"
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "us_east_1"

  assume_role {
    role_arn = "arn:aws:iam::269807742353:role/reporting-developer"
  }
}
