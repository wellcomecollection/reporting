workflow "Deploy" {
  on       = "push"
  resolves = [
    "Deploy: Sierra varFields λ"
  ]
}

action "Master" {
  uses = "actions/bin/filter@master"
  args = "branch master"
}

action "Test: Sierra varFields λ test" {
  uses  = "./actions/test_lambda/"
  args  = [
    "sierra_varFields"
  ]
}

action "Deploy: Sierra varFields λ" {
  needs = [
    "Test: Sierra varFields λ test",
    "Master",
  ]
  uses  = "./actions/deploy_lambda/"
  args  = [
    "sierra_varFields"
  ]
}
