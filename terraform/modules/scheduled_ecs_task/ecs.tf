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

  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

resource "aws_iam_role_policy" "task_execution_role" {
  name   = "${var.name}-task-execution-policy"
  role   = "${aws_iam_role.task_execution_role.id}"
  policy = "${data.aws_iam_policy_document.task_execution_role_policy.json}"
}

## ECS task role

resource "aws_iam_role" "task_role" {
  name               = "${var.name}-task-role"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}
