locals {
  miro_reindex_topic_arn = "${data.terraform_remote_state.shared_infra.reporting_miro_reindex_topic_arn}"
  miro_updates_topic_arn = "${data.terraform_remote_state.shared_infra.miro_updates_topic_arn}"

  miro_inventory_topic_arn = "${data.terraform_remote_state.shared_infra.reporting_miro_inventory_reindex_topic_arn}"

  sierra_reindex_topic_arn = "${data.terraform_remote_state.shared_infra.reporting_sierra_reindex_topic_arn}"
  sierra_updates_topic_arn = "${data.terraform_remote_state.sierra_adapter.merged_bibs_topic_arn}"

  calm_reindex_topic_arn = "${data.terraform_remote_state.reindexer.outputs.calm_reindexer_topic_arn}"
  calm_updates_topic_arn = "${data.terraform_remote_state.calm_adapter.calm_adapter_topic}"

  infra_bucket = "${data.terraform_remote_state.shared_infra.infra_bucket}"

  miro_vhs_read_policy = "${data.terraform_remote_state.infra_critical.vhs_miro_read_policy}"

  miro_inventory_vhs_read_policy = "${data.terraform_remote_state.infra_critical.vhs_miro_inventory_read_policy}"

  sierra_vhs_read_policy = "${data.terraform_remote_state.infra_critical.vhs_sierra_read_policy}"

  calm_vhs_read_policy = "${data.terraform_remote_state.calm_adapter.vhs_read_policy}"
}
