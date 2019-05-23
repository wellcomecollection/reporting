workflow "Test and deploy lambdas" {
  on       = "push"
  resolves = [
    "Deploy: miro_inventory_transformer",
    "Deploy: miro_transformer",
    "Deploy: sierra_transformer",
    "Deploy: sierra_varfields_transformer",
  ]
}

# It seems a little nonsensicle to have master rely on the tests, and then
# deploy rely on "Master", but if the deploy needed the
# "Master" and the tests, the tests wouldn't run if we weren't on
# master, as that's how the action dependencies are setup.

# See this example for a similar setup
# https://github.com/actions/bin/tree/master/filter

# miro_inventory_transformer
action "Master: miro_inventory_transformer" {
  needs = [
    "Test: miro_inventory_transformer"
  ]
  uses = "actions/bin/filter@master"
  args = "branch deploy_action"
}

action "Test: miro_inventory_transformer" {
  uses  = "./actions/test_lambda/"
  args  = [
    "miro_inventory_transformer"
  ]
}

action "Deploy: miro_inventory_transformer" {
  needs = [
    "Master: miro_inventory_transformer",
  ]
  uses  = "./actions/deploy_lambda/"
  args  = [
    "miro_inventory_transformer"
  ]
  secrets = [
    "AWS_ACCESS_KEY_ID",
    "AWS_SECRET_ACCESS_KEY"
  ]
}

# miro_transformer
action "Master: miro_transformer" {
  needs = [
    "Test: miro_transformer"
  ]
  uses = "actions/bin/filter@master"
  args = "branch deploy_action"
}

action "Test: miro_transformer" {
  uses  = "./actions/test_lambda/"
  args  = [
    "miro_transformer"
  ]
}

action "Deploy: miro_transformer" {
  needs = [
    "Master: miro_transformer",
  ]
  uses  = "./actions/deploy_lambda/"
  args  = [
    "miro_transformer"
  ]
  secrets = [
    "AWS_ACCESS_KEY_ID",
    "AWS_SECRET_ACCESS_KEY"
  ]
}

# sierra_transformer
action "Master: sierra_transformer" {
  needs = [
    "Test: sierra_transformer"
  ]
  uses = "actions/bin/filter@master"
  args = "branch deploy_action"
}

action "Test: sierra_transformer" {
  uses  = "./actions/test_lambda/"
  args  = [
    "sierra_transformer"
  ]
}

action "Deploy: sierra_transformer" {
  needs = [
    "Master: sierra_transformer",
  ]
  uses  = "./actions/deploy_lambda/"
  args  = [
    "sierra_transformer"
  ]
  secrets = [
    "AWS_ACCESS_KEY_ID",
    "AWS_SECRET_ACCESS_KEY"
  ]
}

# sierra_varfields_transformer
action "Master: sierra_varfields_transformer" {
  needs = [
    "Test: sierra_varfields_transformer"
  ]
  uses = "actions/bin/filter@master"
  args = "branch deploy_action"
}

action "Test: sierra_varfields_transformer" {
  uses  = "./actions/test_lambda/"
  args  = [
    "sierra_varfields_transformer"
  ]
}

action "Deploy: sierra_varfields_transformer" {
  needs = [
    "Master: sierra_varfields_transformer",
  ]
  uses  = "./actions/deploy_lambda/"
  args  = [
    "sierra_varfields_transformer"
  ]
  secrets = [
    "AWS_ACCESS_KEY_ID",
    "AWS_SECRET_ACCESS_KEY"
  ]
}
