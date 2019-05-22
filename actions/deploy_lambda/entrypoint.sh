#!/bin/sh
set -eu

LAMBDA_NAME=$1
LAMBDA_DIR="./lambdas/$LAMBDA_NAME"

cd $LAMBDA_DIR
  if test -f "./requirements.txt"; then
    pip install -r requirements.txt -t .
  fi

  zip -r $LAMBDA_NAME.zip .
  echo "Finished building $LAMBDA_NAME"
cd ../../

