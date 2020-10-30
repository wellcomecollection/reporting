data "aws_secretsmanager_secret_version" "elastic_secret_id" {
  secret_id = local.elastic_secret_id
}

data "aws_secretsmanager_secret_version" "slack_secret_id" {
  secret_id = local.slack_secret_id
}

locals {
  elastic_secret_id = "reporting/search_elastic_credentials"
  slack_secret_id   = "reporting/slack_webhook_url"
}
