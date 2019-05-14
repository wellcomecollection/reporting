resource "aws_s3_bucket" "reporting_lambdas" {
  bucket = "wellcomecollection-reporting-lambdas"
  acl    = "private"
}

resource "aws_iam_role" "reporting_lambda_role" {
  name               = "ReportingLambda"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_policy_document.json}"
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution_policy_attachement" {
  role       = "${aws_iam_role.reporting_lambda_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "s3_get_objects_policy_attachement" {
  role       = "${aws_iam_role.reporting_lambda_role.id}"
  policy_arn = "${aws_iam_policy.s3_get_objects_policy.arn}"
}

resource "aws_lambda_layer_version" "elastic_lambda_layer" {
  layer_name          = "elastic_lambda_layer"
  description         = "The ElasticSearch dependency for use within reporting lambdas"
  s3_bucket           = "${aws_s3_bucket.reporting_lambdas.bucket}"
  s3_key              = "elastic_lambda_layer.zip"
  compatible_runtimes = ["python3.6", "python3.7"]

  # source_code_hash = "${filebase64sha256("../lambdas/elastic_lambda_layer/elastic_lambda_layer.zip")}"
}

resource "aws_lambda_function" "sierra_varFields" {
  function_name = "sierra_varFields"
  description   = "Grab and store the Sierra varFields in an Elasticsearch index"
  s3_bucket     = "${aws_s3_bucket.reporting_lambdas.bucket}"
  s3_key        = "sierra_varFields.zip"
  role          = "${aws_iam_role.reporting_lambda_role.arn}"
  handler       = "sierra_varFields.main"

  # source_code_hash = "${filebase64sha256("../lambdas/sierra_varFields/sierra_varFields.zip")}"
  runtime = "python3.7"
  layers  = ["${aws_lambda_layer_version.elastic_lambda_layer.arn}"]
}

# Sierra updates permissions
resource "aws_lambda_permission" "with_sns_sierra_updates" {
  statement_id  = "AllowExecutionFromSNSSierraUpdates"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.sierra_varFields.function_name}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${local.sierra_updates_topic_arn}"
}

resource "aws_sns_topic_subscription" "reporting_lambda_sns_sierra_updates_topic_subscription" {
  protocol  = "lambda"
  topic_arn = "${local.sierra_updates_topic_arn}"
  endpoint  = "${aws_lambda_function.sierra_varFields.arn}"
}

# Reindex permissions
resource "aws_lambda_permission" "with_sns_sierra_reindex" {
  statement_id  = "AllowExecutionFromSNSReindex"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.sierra_varFields.function_name}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${local.sierra_reindex_topic_arn}"
}

resource "aws_sns_topic_subscription" "reporting_lambda_sns_sierra_reindex_topic_subscription" {
  protocol  = "lambda"
  topic_arn = "${local.sierra_reindex_topic_arn}"
  endpoint  = "${aws_lambda_function.sierra_varFields.arn}"
}

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

resource "aws_iam_policy" "s3_get_objects_policy" {
  name   = "S3GetObjectsPolicy"
  policy = "${data.aws_iam_policy_document.s3_get_objects_policy_document.json}"
}

data "aws_iam_policy_document" "s3_get_objects_policy_document" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::wellcomecollection-vhs-sourcedata-sierra/*"]
  }
}

# KMS / Secrets stuff
resource "aws_kms_key" "lambda_env_vars_kms_key" {
  description = "Encrypt / decrypt lambda env vars"
}

resource "aws_kms_alias" "lambda_env_vars_alias" {
  name          = "alias/lambda/env-vars"
  target_key_id = "${aws_kms_key.lambda_env_vars_kms_key.key_id}"
}

data "aws_secretsmanager_secret" "es_reporting_credentials" {
  name = "prod/Elasticsearch/ReportingCredentials"
}

data "aws_iam_policy_document" "kms_decrypt" {
  statement {
    actions   = ["kms:Decrypt"]
    resources = ["${aws_kms_key.lambda_env_vars_kms_key.arn}"]
  }
}

# TODO: We could namespace this
data "aws_iam_policy_document" "secrets_manager_read" {
  statement {
    actions   = ["secretsmanager:Get*"]
    resources = ["${data.aws_secretsmanager_secret.es_reporting_credentials.arn}"]
  }
}

resource "aws_iam_policy" "kms_decrypt_policy" {
  name   = "KMSDecrypt"
  policy = "${data.aws_iam_policy_document.kms_decrypt.json}"
}

resource "aws_iam_policy" "secrets_manager_get_policy" {
  name   = "SecretsManagerGet"
  policy = "${data.aws_iam_policy_document.secrets_manager_read.json}"
}

resource "aws_iam_role_policy_attachment" "kms_decrypt_policy_policy_attachement" {
  role       = "${aws_iam_role.reporting_lambda_role.id}"
  policy_arn = "${aws_iam_policy.kms_decrypt_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "secrets_manager_get_policy_attachement" {
  role       = "${aws_iam_role.reporting_lambda_role.id}"
  policy_arn = "${aws_iam_policy.secrets_manager_get_policy.arn}"
}
