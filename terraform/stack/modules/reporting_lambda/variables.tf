variable "timeout" {
  default = 25
}

variable "name" {}
variable "description" {}

variable "environment_variables" {
  description = "Environment variables to pass to the Lambda"
  type        = "map"

  # environment cannot be empty so we need to pass at least one value
  default = {
    EMPTY_VARIABLE = ""
  }
}

variable "topic_arns" {
  type        = "list"
  description = "Topic arn for the SNS topic to subscribe the queue to"
}

variable "topic_count" {
  default = 1
}

variable "log_retention_in_days" {
  default = 7
}

variable "vhs_read_policy" {}
