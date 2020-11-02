terraform {
  required_version = ">= 0.11.12"

  backend "s3" {
    role_arn = "arn:aws:iam::269807742353:role/reporting-developer"

    bucket         = "wellcomecollection-reporting-infra"
    key            = "terraform/reporting_search_reporter.tfstate"
    dynamodb_table = "terraform-locktable"
    region         = "eu-west-1"
  }
}

data "terraform_remote_state" "shared" {
  backend = "s3"

  config = {
    role_arn = "arn:aws:iam::760097843905:role/platform-read_only"
    bucket   = "wellcomecollection-platform-infra"
    key      = "terraform/platform-infrastructure/shared.tfstate"
    region   = "eu-west-1"
  }
}

locals {
  lambda_error_alarm_arn = data.terraform_remote_state.shared.outputs.lambda_error_alarm_arn
}
