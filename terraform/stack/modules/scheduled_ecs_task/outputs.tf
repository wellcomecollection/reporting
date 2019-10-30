output "task_execution_role_id" {
  value = "${aws_iam_role.task_execution_role.id}"
}

output "task_role_id" {
  value = "${aws_iam_role.task_role.id}"
}

output "scheduled_task_cloudwatch_role_id" {
  value = "${aws_iam_role.scheduled_task_cloudwatch_role.id}"
}

output "scheduled_task_arn" {
  value = "${aws_ecs_task_definition.scheduled_task.arn}"
}
