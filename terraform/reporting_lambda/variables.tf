variable "timeout" {
  default = 25
}

variable "name" {}
variable "description" {}

variable "topic_arns" {
  type        = list
  description = "Topic arn for the SNS topic to subscribe the queue to"
}

variable "topic_count" {
  default = 1
}

variable "log_retention_in_days" {
  default = 7
}

variable "vhs_read_policy" {}
