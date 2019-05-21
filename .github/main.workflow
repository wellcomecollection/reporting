workflow "Master" {
  on       = "push"
  resolves = [
    "Deploy: Sierra varFields λ",
    "Deploy: Elastic layer λ"
  ]
}

workflow "PRs" {
  on       = "push"
  resolves = [
    "Test: Sierra varFields λ",
    "Test: Elastic layer λ"
  ]
}

action "Is master branch" {
  uses = "actions/bin/filter@master"
  args = "branch master"
}

# sierra varfields
action "Test: Sierra varFields λ" {
  uses  = "./actions/test_lambda/"
  args  = [
    "sierra_varFields"
  ]
}

action "Deploy: Sierra varFields λ" {
  needs = [
    "Test: Sierra varFields λ",
    "Is master branch",
  ]
  uses  = "./actions/deploy_lambda/"
  args  = [
    "sierra_varFields"
  ]
}

# Elastic layer
action "Test: Elastic layer λ" {
  uses  = "./actions/test_lambda/"
  args  = [
    "elastic_lambda_layer"
  ]
}

action "Deploy: Elastic layer λ" {
  needs = [
    "Test: Sierra varFields λ",
    "Is master branch",
  ]
  uses  = "./actions/deploy_lambda/"
  args  = [
    "elastic_lambda_layer"
  ]
}
