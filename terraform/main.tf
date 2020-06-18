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

module "lambda_sierra_sourcedata_transformer" {
  source      = "./reporting_lambda"
  name        = "sierra_sourcedata_transformer"
  description = "Send unmodified sierra source data to elastic"

  vhs_read_policy = "${local.sierra_vhs_read_policy}"

  topic_arns = [
    "${local.sierra_reindex_topic_arn}",
    "${local.sierra_updates_topic_arn}",
  ]

  topic_count = 2
}

module "calm_sourcedata_lambda" {
  source      = "./reporting_lambda"
  name        = "calm_sourcedata"
  description = "Send unmodified calm source data to elastic"

  vhs_read_policy = "${local.calm_vhs_read_policy}"

  topic_arns = [
    "${local.calm_reindex_topic_arn}",
    "${local.calm_updates_topic_arn}",
  ]

  topic_count = 2
}

output "miro_transformer_s3_object_version_id" {
  value = "${module.lambda_miro_transformer.s3_object_version_id}"
}

output "miro_inventory_transformer_s3_object_version_id" {
  value = "${module.lambda_miro_inventory_transformer.s3_object_version_id}"
}

output "sierra_transformer_s3_object_version_id" {
  value = "${module.lambda_sierra_transformer.s3_object_version_id}"
}

output "sierra_varfields_s3_object_version_id" {
  value = "${module.lambda_sierra_varfields_transformer.s3_object_version_id}"
}
