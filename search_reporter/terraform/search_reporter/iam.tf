data "aws_iam_policy_document" "read_secrets" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      data.aws_secretsmanager_secret_version.elastic_secret_id.arn,
      data.aws_secretsmanager_secret_version.slack_secret_id.arn,
    ]
  }
}

resource "aws_iam_role_policy" "search_reporter_read_secrets" {
  role   = module.search_reporter.role_name
  policy = data.aws_iam_policy_document.read_secrets.json
}
