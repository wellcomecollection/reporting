#!/bin/sh
set -eu

LAMBDA_NAME=$1
LAMBDA_DIR="./lambdas/$LAMBDA_NAME"

cd $LAMBDA_DIR
  if test -f "./requirements.txt"; then
    pip install -r requirements.txt
  fi

  python3 ./test.py
  echo "Finished testing $LAMBDA_NAME"
cd ../../
