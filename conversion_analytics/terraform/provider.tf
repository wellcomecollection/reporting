provider "aws" {
  region  = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::130871440101:role/experience-developer"
  }
}

locals {
  default_tags = {
    TerraformConfigurationURL = "https://github.com/wellcomecollection/search-logger/tree/master/terraform"
  }
}
