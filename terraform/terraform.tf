terraform {
  required_version = ">= 0.11.12"

  backend "s3" {
    role_arn = "arn:aws:iam::760097843905:role/developer"

    bucket         = "wellcomecollection-platform-infra"
    key            = "terraform/reporting_test.tfstate"
    dynamodb_table = "terraform-locktable"
    region         = "eu-west-1"
  }
}

data "terraform_remote_state" "shared_infra" {
  backend = "s3"

  config {
    role_arn = "arn:aws:iam::760097843905:role/developer"

    bucket = "wellcomecollection-platform-infra"
    key    = "terraform/shared_infra.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "sierra_adapter" {
  backend = "s3"

  config {
    role_arn = "arn:aws:iam::760097843905:role/developer"

    bucket = "wellcomecollection-platform-infra"
    key    = "terraform/sierra_adapter.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  region  = "eu-west-1"
  version = "~> 2.8"

  assume_role {
    role_arn = "arn:aws:iam::760097843905:role/developer"
  }
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "lambda_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "reporting_lambda_role" {
  name               = "ReportingLambda"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_policy_document.json}"
}

resource "aws_lambda_layer_version" "elastic_lambda_layer" {
  layer_name          = "elastic_lambda_layer"
  description         = "The ElasticSearch dependency for use within reporting lambdas"
  s3_bucket           = "wellcomecollection-platform-infra"
  s3_key              = "lambdas/reporting/elastic_lambda_layer.zip"
  compatible_runtimes = ["python3.6", "python3.7"]
  source_code_hash    = "${filebase64sha256("../lambdas/elastic_lambda_layer/elastic_lambda_layer.zip")}"
}

resource "aws_lambda_function" "sierra_varFields" {
  function_name    = "sierra_varFields"
  description      = "Grab and store the Sierra varFields in an Elasticsearch index"
  s3_bucket        = "wellcomecollection-platform-infra"
  s3_key           = "lambdas/reporting/sierra_varFields.zip"
  role             = "${aws_iam_role.reporting_lambda_role.arn}"
  handler          = "sierra_varFields.main"
  source_code_hash = "${filebase64sha256("../lambdas/sierra_varFields/sierra_varFields.zip")}"
  runtime          = "python3.7"
  layers           = ["${aws_lambda_layer_version.elastic_lambda_layer.arn}"]
}

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.sierra_varFields.function_name}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${local.sierra_updates_topic_arn}"
}

resource "aws_sns_topic_subscription" "reporting_lambda_sns_topic_subscription" {
  topic_arn = "${local.sierra_updates_topic_arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.sierra_varFields.arn}"
}
