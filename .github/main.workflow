workflow "Deploy" {
 on       = "push"
 resolves = ["S3Copy"]
}

action "Master" {
  uses = "actions/bin/filter@master"
  args = "branch master"
}

action "Zip" {
  needs = ["Master"]
  uses = "./actions/zip/"
}

action "S3Copy" {
  needs   = ["Zip"]
  uses    = "actions/aws/cli@master"
  args    = "s3 cp ./lambdas/sierra_varFields/sierra_varFields.zip s3://wellcomecollection-reporting-lambdas/"
  secrets = ["AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
}
