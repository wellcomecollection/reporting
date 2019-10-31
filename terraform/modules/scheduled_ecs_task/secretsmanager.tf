# Permission to read from secretsmanager
data "aws_secretsmanager_secret" "es_details" {
  name = "prod/Elasticsearch/ReportingCredentials"
}

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
  role       = "${aws_iam_role.task_role.id}"
  policy_arn = "${aws_iam_policy.secrets_manager_es_details_read.arn}"
}

# Permission to decrypt secret with KMS
resource "aws_kms_key" "ecs_es_details" {
  description = "Encrypt / decrypt ES details"
}

resource "aws_kms_alias" "lambda_env_vars" {
  name          = "alias/ecs/${var.name}_es_details"
  target_key_id = "${aws_kms_key.ecs_es_details.key_id}"
}

data "aws_iam_policy_document" "kms_decrypt_env_vars" {
  statement {
    actions   = ["kms:Decrypt"]
    resources = ["${aws_kms_key.ecs_es_details.arn}"]
  }
}

resource "aws_iam_policy" "kms_decrypt_env_vars" {
  name        = "DecryptKMS-${var.name}"
  description = "Allow the decrypting of keys via KMS"
  policy      = "${data.aws_iam_policy_document.kms_decrypt_env_vars.json}"
}

resource "aws_iam_role_policy_attachment" "lambda_kinesis_kms_decrypt" {
  role       = "${aws_iam_role.task_role.id}"
  policy_arn = "${aws_iam_policy.kms_decrypt_env_vars.arn}"
}
