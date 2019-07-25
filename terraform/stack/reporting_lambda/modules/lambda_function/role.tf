resource "aws_iam_role" "lambda_iam_role" {
  name               = "lambda_${var.name}_iam_role"
  assume_role_policy = "${data.aws_iam_policy_document.assume_lambda_role.json}"
}

data "aws_iam_policy_document" "assume_lambda_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}


data "aws_secretsmanager_secret" "es_details" {
  name = "prod/Elasticsearch/ReportingCredentials"
}

# Decrypt secret
data "aws_iam_policy_document" "kms_decrypt_env_vars" {
  statement {
    actions   = ["kms:Decrypt"]
    resources = ["${data.aws_secretsmanager_secret.es_details.arn}"]
  }
}

resource "aws_iam_policy" "kms_decrypt_env_vars" {
  name        = "DecryptKMS-${var.name}"
  description = "Allow the decrypting of keys via KMS"
  policy      = "${data.aws_iam_policy_document.kms_decrypt_env_vars.json}"
}

resource "aws_iam_role_policy_attachment" "lambda_kinesis_kms_decrypt" {
  role       = "${aws_iam_role.lambda_iam_role.id}"
  policy_arn = "${aws_iam_policy.kms_decrypt_env_vars.arn}"
}

# Read secret
data "aws_iam_policy_document" "secrets_manager_es_details_read" {
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["${data.aws_secretsmanager_secret.es_details.arn}"]
  }
}

resource "aws_iam_policy" "secrets_manager_es_details_read" {
  name        = "ReadEsDetails-${var.name}"
  description = "Read ES details"
  policy      = "${data.aws_iam_policy_document.secrets_manager_es_details_read.json}"
}

resource "aws_iam_role_policy_attachment" "secrets_manager_es_details_read" {
  role       = "${aws_iam_role.lambda_iam_role.id}"
  policy_arn = "${aws_iam_policy.secrets_manager_es_details_read.arn}"
}