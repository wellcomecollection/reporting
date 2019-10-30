locals {
  platform_account_arn = "arn:aws:iam::760097843905:root"
}

data "template_file" "pgp_key" {
  template = "${file("${path.module}/wellcomedigitalplatform.key")}"
}

 module "account" {
  source = "git::https://github.com/wellcometrust/terraform.git//iam/prebuilt/account?ref=v19.13.0"

  admin_principals          = ["${local.platform_account_arn}"]
  read_only_principals      = ["${local.platform_account_arn}"]
  billing_principals        = ["${local.platform_account_arn}"]
  developer_principals      = ["${local.platform_account_arn}"]
  infrastructure_principals = ["${local.platform_account_arn}"]
  monitoring_principals     = ["${local.platform_account_arn}"]

  pgp_key = "${data.template_file.pgp_key.rendered}"
}
