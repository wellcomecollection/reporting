# Lambda

This set of scripts and files deploys the lambda which acts between kinesis and elastic.  
NB this requires a valid set of AWS credentials which can assume the `experience-admin` role.

## Updating the lambda

- edit [index.js](index.js)
- run `yarn deploy` to build the lambda and send a zipped version to s3.
- navigate to the neighbouring `terraform` directory and run `terraform init`, `terraform plan`, and `terraform apply`. The only change should be an version update to the lambda.

## Running tests

Run `yarn test`
