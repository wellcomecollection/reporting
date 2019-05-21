workflow "Test and deploy lambdas" {
  on       = "push"
  resolves = [
    "Deploy: Sierra varFields λ",
    "Deploy: Elastic layer λ"
  ]
}

# It seems a little nonsensicle to have master rely on the tests, and then
# deploy rely on "Is master branch", but if the deploy needed the
# "Is master branch" and the tests, the tests wouldn't run if we weren't on
# master, as that's how the action dependencies are setup.

# See this example for a similar setup
# https://github.com/actions/bin/tree/master/filter

action "Is master branch" {
  needs = [
    "Test: Elastic layer λ",
    "Test: Sierra varFields λ"
  ]
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
    "Is master branch",
  ]
  uses  = "./actions/deploy_lambda/"
  args  = [
    "elastic_lambda_layer"
  ]
}
