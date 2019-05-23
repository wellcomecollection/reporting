#!/bin/sh
set -eu

LAMBDA_NAME=$1
LAMBDA_DIR="./lambdas/$LAMBDA_NAME/src"

cd $LAMBDA_DIR
  if test -f "./requirements.txt"; then
    pip install -r requirements.txt -t .
  fi

  zip -r $LAMBDA_NAME.zip .
  aws s3 cp $LAMBDA_NAME.zip s3://wellcomecollection-reporting-lambdas/$LAMBDA_NAME.zip
  echo "Finished deploying $LAMBDA_NAME"
cd ../../

