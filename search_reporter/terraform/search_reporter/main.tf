module "search_reporter" {
  source = "../../modules/lambda"

  name = "search_reporter-${var.deployment_service_env}"

  s3_bucket = var.lambda_upload_bucket
  s3_key    = "lambdas/reporting/search_reporter.zip"

  description     = "Reports daily search metrics to slack"
  alarm_topic_arn = var.lambda_error_alarm_arn
  timeout         = 60

  env_vars = {
    ELASTIC_SECRET_ID = local.elastic_secret_id
    SLACK_SECRET_ID   = local.slack_secret_id
  }

  log_retention_in_days = 30

  handler = "search_reporter"
}
