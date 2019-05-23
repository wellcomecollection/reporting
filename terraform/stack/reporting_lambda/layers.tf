resource "aws_lambda_layer_version" "utils_layer" {
  layer_name          = "utils_layer"
  description         = "Utils for reporting lambdas"
  s3_bucket           = "wellcomecollection-reporting-lambdas"
  s3_key              = "utils_layer.zip"
  compatible_runtimes = ["python3.6", "python3.7"]
}
