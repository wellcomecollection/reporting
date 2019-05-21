#!/bin/sh
set -eu

LAMBDA_NAME=$1
LAMBDA_DIR="./lambdas/$1"



cd $LAMBDA_DIR
  if test -f "./requirements.txt"; then
    pip install -r requirements.txt
  fi

  python3 ./test.py
cd ../../
