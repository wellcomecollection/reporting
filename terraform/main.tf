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
