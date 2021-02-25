locals {
  miro_reindex_topic_arn = data.terraform_remote_state.shared_infra.outputs.reporting_miro_reindex_topic_arn
  miro_updates_topic_arn = data.terraform_remote_state.shared_infra.outputs.miro_updates_topic_arn

  miro_inventory_topic_arn = data.terraform_remote_state.shared_infra.outputs.reporting_miro_inventory_reindex_topic_arn

  sierra_reindex_topic_arn  = data.terraform_remote_state.shared_infra.outputs.reporting_sierra_reindex_topic_arn
  sierra_bibs_topic_arn     = data.terraform_remote_state.sierra_adapter.outputs.merged_bibs_topic_arn
  sierra_items_topic_arn    = data.terraform_remote_state.sierra_adapter.outputs.merged_items_topic_arn
  sierra_holdings_topic_arn = data.terraform_remote_state.sierra_adapter.outputs.merged_holdings_topic_arn

  calm_reindex_topic_arn = data.terraform_remote_state.reindexer.outputs.calm_reindexer_topic_arn
  calm_updates_topic_arn = data.terraform_remote_state.calm_adapter.outputs.calm_adapter_topic_arn

  infra_bucket = data.terraform_remote_state.shared_infra.outputs.infra_bucket

  miro_vhs_read_policy = data.terraform_remote_state.infra_critical.outputs.vhs_miro_read_policy

  miro_inventory_vhs_read_policy = data.terraform_remote_state.infra_critical.outputs.vhs_miro_inventory_read_policy

  sierra_vhs_read_policy         = data.terraform_remote_state.sierra_adapter.outputs.vhs_read_policy
  sierra_vhs_assumable_read_role = data.terraform_remote_state.sierra_adapter.outputs.vhs_assumable_read_role

  calm_vhs_read_policy = data.terraform_remote_state.calm_adapter.outputs.vhs_read_policy
  calm_vhs_assumable_read_role = data.terraform_remote_state.calm_adapter.outputs.assumable_read_role
}
