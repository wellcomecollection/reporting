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
