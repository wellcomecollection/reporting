output "miro_identifiers_s3_object_version_id" {
  value = "${module.lambda_miro_identifiers.s3_object_version_id}"
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
