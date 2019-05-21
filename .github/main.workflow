workflow "Master" {
  on       = "push"
  resolves = [
    "Deploy: Sierra varFields λ"
  ]
}

workflow "PRs" {
  on       = "push"
  resolves = [
    "Test: Sierra varFields λ test"
  ]
}

action "Is master branch" {
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
    "Is master branch",
  ]
  uses  = "./actions/deploy_lambda/"
  args  = [
    "sierra_varFields"
  ]
}
