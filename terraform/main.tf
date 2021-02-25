module "calm_sourcedata_lambda" {
  source      = "./reporting_lambda"
  name        = "calm_sourcedata"
  description = "Send unmodified calm source data to elastic"

  vhs_read_policy = local.calm_vhs_read_policy
  assumable_read_role = local.calm_vhs_assumable_read_role

  topic_arns = [
    local.calm_updates_topic_arn,
    # local.calm_reindex_topic_arn,
  ]

  topic_count = 2
}

module "sierra_lambda" {
  source      = "./reporting_lambda"
  name        = "new_sierra_transformer"
  description = "Index Sierra source data in Elasticsearch"

  vhs_read_policy     = local.sierra_vhs_read_policy
  assumable_read_role = local.calm_vhs_assumable_read_role

  topic_arns = [
    local.sierra_reindex_topic_arn,
    local.sierra_bibs_topic_arn,
    local.sierra_items_topic_arn,
    local.sierra_holdings_topic_arn,
  ]

  topic_count = 4
}
