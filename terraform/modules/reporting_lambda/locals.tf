locals {
  sierra_reindex_topic_arn = "${data.terraform_remote_state.shared_infra.reporting_sierra_reindex_topic_arn}"
  sierra_updates_topic_arn = "${data.terraform_remote_state.sierra_adapter.merged_bibs_topic_arn}"
}
