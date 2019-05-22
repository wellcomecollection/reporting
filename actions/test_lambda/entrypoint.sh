#!/bin/sh
set -eu

LAMBDA_NAME=$1
LAMBDA_DIR="./lambdas/$LAMBDA_NAME/src"

cd $LAMBDA_DIR
  if [ -f "./requirements.txt" ]
  then
    echo "Installing pip requirements"
    pip3 install -r requirements.txt
  else
    echo "No pip requirements"
  fi

  pytest .
  echo "Finished testing $LAMBDA_NAME"
cd ../../../
