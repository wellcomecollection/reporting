module "lambda_miro_transformer" {
  source      = "./reporting_lambda"
  name        = "miro_transformer"
  description = "Transform miro source data and send to ES."

  vhs_read_policy = "${local.miro_vhs_read_policy}"

  topic_arns = [
    "${local.miro_reindex_topic_arn}",
    "${local.miro_updates_topic_arn}",
  ]

  topic_count = 2
}

module "lambda_miro_inventory_transformer" {
  source      = "./reporting_lambda"
  name        = "miro_inventory_transformer"
  description = "Transform miro inventory source data and send to ES."

  vhs_read_policy = "${local.miro_inventory_vhs_read_policy}"

  topic_arns = ["${local.miro_inventory_topic_arn}"]
}

module "lambda_sierra_transformer" {
  source      = "./reporting_lambda"
  name        = "sierra_transformer"
  description = "Transform sierra source data and send to ES."

  vhs_read_policy = "${local.sierra_vhs_read_policy}"

  topic_arns = [
    "${local.sierra_reindex_topic_arn}",
    "${local.sierra_updates_topic_arn}",
  ]

  topic_count = 2
}

module "lambda_sierra_varfields_transformer" {
  source      = "./reporting_lambda"
  name        = "sierra_varfields_transformer"
  description = "Send plain sierra varfields to ES."

  vhs_read_policy = "${local.sierra_vhs_read_policy}"

  topic_arns = [
    "${local.sierra_reindex_topic_arn}",
    "${local.sierra_updates_topic_arn}",
  ]

  topic_count = 2
}
