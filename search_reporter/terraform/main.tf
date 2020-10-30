module "search_reporter" {
  source = "./search_reporter"

  deployment_service_env = var.deployment_service_env
  lambda_error_alarm_arn = var.lambda_error_alarm_arn
  lambda_upload_bucket   = "wellcomecollection-platform-infra"
}
