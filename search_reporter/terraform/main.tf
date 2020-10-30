module "search_reporter" {
  source = "./search_reporter"

  deployment_service_env = "prod"
  lambda_error_alarm_arn = local.lambda_error_alarm_arn
  lambda_upload_bucket   = "wellcomecollection-platform-infra"
}
