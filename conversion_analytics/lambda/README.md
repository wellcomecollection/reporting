# Lambda

This set of scripts and files deploys the lambda which acts between kinesis and elastic (see [architecture diagram](../architecture.svg)).  
NB this requires a valid set of AWS credentials which can assume the `experience-developer` role.

## Updating the lambda

- edit [index.js](index.js)
- run `yarn install --dev` to install dev dependencies
- run `yarn build` to zip a new version of the lambda
- run `yarn deploy` to send the zip to s3
- navigate to the neighbouring `terraform` directory and run `terraform init`, `terraform plan`, and `terraform apply`. The only change should be an version update to the lambda.

## Running tests

Run `yarn test`
