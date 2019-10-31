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
  name               = "${var.name}-task-execution-role"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}


resource "aws_iam_role_policy_attachment" "task_execution_role" {
  role       = "${aws_iam_role.task_execution_role.id}"
  policy_arn = "${aws_iam_policy.task_execution_role.arn}"
}

## ECS task role

resource "aws_iam_role" "task_role" {
  name               = "${var.name}-task-role"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

# Permission for ECS task role to read from secretsmanager
data "aws_secretsmanager_secret" "es_details" {
  name = "prod/Elasticsearch/ReportingCredentials"
}



resource "aws_iam_role_policy_attachment" "secrets_manager_es_details_read" {
  role       = "${aws_iam_role.task_role.id}"
  policy_arn = "${aws_iam_policy.secrets_manager_es_details_read.arn}"
}

# Permission for ECS task role to decrypt secrets with KMS
resource "aws_kms_key" "ecs_es_details" {
  description = "Encrypt / decrypt ES details"
}

resource "aws_kms_alias" "ecs_env_vars" {
  name          = "alias/ecs/${var.name}_es_details"
  target_key_id = "${aws_kms_key.ecs_es_details.key_id}"
}




resource "aws_iam_role_policy_attachment" "lambda_kinesis_kms_decrypt" {
  role       = "${aws_iam_role.task_role.id}"
  policy_arn = "${aws_iam_policy.kms_decrypt_env_vars.arn}"
}
