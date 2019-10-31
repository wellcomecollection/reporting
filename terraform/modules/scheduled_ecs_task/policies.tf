# Assume role
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Cloudwatch policy
data "aws_iam_policy_document" "cloudwatch_policy" {
  statement {
    effect    = "Allow"
    actions   = ["ecs:RunTask"]
    resources = ["*"]
  }

  statement {
    effect  = "Allow"
    actions = ["iam:PassRole"]
  }
}

resource "aws_iam_policy" "scheduled_task_cloudwatch_role" {
  name   = "${var.name}-task-execution-policy"
  policy = "${data.aws_iam_policy_document.task_execution_role.json}"
}

# Execution role policy
data "aws_iam_policy_document" "task_execution_role" {
  statement {
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "task_execution_role" {
  name   = "${var.name}-task-execution-policy"
  policy = "${data.aws_iam_policy_document.task_execution_role.json}"
}

# Read from secretsmanager
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

# Decrypt KMS
data "aws_iam_policy_document" "kms_decrypt_env_vars" {
  statement {
    actions   = ["kms:Decrypt"]
    resources = ["${aws_kms_key.ecs_es_details.arn}"]
  }
}

resource "aws_iam_policy" "kms_decrypt_env_vars" {
  name   = "DecryptKMS-${var.name}"
  policy = "${data.aws_iam_policy_document.kms_decrypt_env_vars.json}"
}
