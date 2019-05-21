workflow "Deploy" {
  on       = "push"
  resolves = [
    "Sierra varFields λ"
  ]
}

action "Master" {
  uses = "actions/bin/filter@master"
  args = "branch master"
}

action "Sierra varFields λ test" {
  uses  = "./actions/test_lambda/"
  args  = [
    "sierra_varFields"
  ]
}

action "Sierra varFields λ" {
  needs = [
    "Master",
    "Sierra varFields λ test"
  ]
  uses  = "./actions/deploy_lambda/"
  args  = [
    "sierra_varFields"
  ]
}
