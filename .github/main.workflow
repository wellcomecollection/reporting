workflow "Deploy" {
 on       = "push"
 resolves = ["S3Copy"]
}

action "Master" {
  uses = "actions/bin/filter@master"
  args = "branch master"
}

action "Test Sierra varFields λ" {
  uses  = "./actions/test_lambda/"
  args  = [
    "sierra_varFields"
  ]
}

action "Deploy Sierra varFields λ" {
  needs = ["Master", "Test Sierra varFields λ"]
  uses  = "./actions/deploy_lambda/"
  args  = [
    "sierra_varFields"
  ]
}
