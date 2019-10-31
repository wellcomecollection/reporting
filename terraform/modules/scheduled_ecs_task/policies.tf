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

data "aws_iam_policy_document" "cloudwatch_policy" {
  statement {
    effect    = "Allow"
    actions   = ["ecs:RunTask"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["${aws_iam_role_policy.task_execution_role.arn}"]
  }
}

data "aws_iam_policy_document" "task_execution_role_policy" {
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
