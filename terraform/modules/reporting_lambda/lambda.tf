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

  # source_code_hash    = "${filebase64sha256("../lambdas/elastic_lambda_layer/elastic_lambda_layer.zip")}"
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

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.sierra_varFields.function_name}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${local.sierra_updates_topic_arn}"
}

# This needs permissions from the SNS account to be able to be created.
# Watch this space.
resource "aws_sns_topic_subscription" "reporting_lambda_sns_topic_subscription" {
  protocol  = "lambda"
  topic_arn = "${local.sierra_updates_topic_arn}"
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
