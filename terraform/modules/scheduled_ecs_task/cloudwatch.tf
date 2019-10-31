## Cloudwatch event

resource "aws_cloudwatch_event_rule" "scheduled_task" {
  name                = "${var.name}_scheduled_task"
  schedule_expression = "${var.schedule_expression}"
}

resource "aws_cloudwatch_event_target" "scheduled_task" {
  target_id = "${var.name}_scheduled_task_target"
  rule      = "${aws_cloudwatch_event_rule.scheduled_task.name}"
  arn       = "${var.cluster_arn}"
  role_arn  = "${aws_iam_role.scheduled_task_cloudwatch_role.arn}"

  ecs_target {
    task_count          = "${var.task_count}"
    task_definition_arn = "${aws_ecs_task_definition.scheduled_task.arn}"
  }
}

## Cloudwatch event role

resource "aws_iam_role" "scheduled_task_cloudwatch_role" {
  name               = "${var.name}-scheduled-task-cloudwatch-role"
  assume_role_policy = "${data.aws_iam_policy_document.cloudwatch_policy.json}"
}