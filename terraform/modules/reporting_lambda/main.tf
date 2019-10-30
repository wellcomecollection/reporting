module "reporting_lambda" {
  source = "./modules/lambda_function"

  name        = "${var.name}"
  description = "${var.description}"
  timeout     = "${var.timeout}"

  alarm_topic_arn = "${data.terraform_remote_state.shared_infra.lambda_error_alarm_arn}"

  s3_bucket = "wellcomecollection-reporting-lambdas"
  s3_key    = "${var.name}.zip"

  log_retention_in_days = "${var.log_retention_in_days}"
}

module "reporting_lambda_trigger" {
  source = "./modules/trigger_sns_subscriptions"

  lambda_function_name = "${module.reporting_lambda.arn}"
  topic_arns           = "${var.topic_arns}"
  topic_count          = "${var.topic_count}"
}
