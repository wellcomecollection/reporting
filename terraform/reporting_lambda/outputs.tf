output "role_name" {
  description = "Name of the IAM role for this Lambda"
  value       = module.reporting_lambda.role_name
}

output "s3_object_version_id" {
  value = module.reporting_lambda.s3_object_version_id
}