module "queue" {
  source = "git::https://github.com/wellcometrust/terraform.git//sqs?ref=v19.6.1"

  # Name of the new queue
  queue_name = "my_first_queue"

  # Name of SNS topics to subscribe to
  topic_names = "${var.top}"

  # SNS topic to send DLQ notifications to
  alarm_topic_arn = "dlq_alarm_topic"

  # How many times a message should be received, and never deleted, before
  # it gets marked as "failed" and sent to the DLQ.
  # (Optional, default 4)
  max_receive_count = 3

  # These are required for constructing some of the fiddly IAM bits
  aws_region = "eu-west-1"
  account_id = "${data.aws_caller_identity.current.account_id}"
}
