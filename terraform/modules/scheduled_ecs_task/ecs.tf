## ECS task definition

resource "aws_ecs_task_definition" "scheduled_task" {
  family                   = "${var.name}-scheduled-task"
  container_definitions    = "${var.container_definitions}"
  requires_compatibilities = ["EC2"]
  network_mode             = "${var.network_mode}"
  execution_role_arn       = "${aws_iam_role.task_execution_role.arn}"
  task_role_arn            = "${aws_iam_role.task_role.arn}"
  cpu                      = "${var.cpu}"
  memory                   = "${var.memory}"
}

## ECS task execution role

resource "aws_iam_role" "task_execution_role" {
  name = "${var.name}-task-execution-role"

  assume_role_policy = "${file("${path.module}/policies/assume-role-policy.json")}"
}

data "template_file" "task_execution_role_policy" {
  template = "${file("${path.module}/policies/ecs-execution-policy.json")}"
}

resource "aws_iam_role_policy" "task_execution_role" {
  name   = "${var.name}-task-execution-policy"
  role   = "${aws_iam_role.task_execution_role.id}"
  policy = "${data.template_file.task_execution_role_policy.rendered}"
}

## ECS task role

resource "aws_iam_role" "task_role" {
  name               = "${var.name}-task-role"
  assume_role_policy = "${file("${path.module}/policies/assume-role-policy.json")}"
}


# attach secretsmanager read policy to task role
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