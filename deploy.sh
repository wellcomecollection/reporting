#!/usr/bin/env bash

set -o errexit
set -o nounset

pushd lambdas/new_sierra_transformer/src
    black *.py
    rm -rf *.zip
    zip -r new_sierra_transformer.zip .
    AWS_PROFILE=reporting-dev aws s3 cp new_sierra_transformer.zip s3://wellcomecollection-reporting-lambdas/new_sierra_transformer.zip
popd

pushd terraform
    terraform apply -auto-approve
popd

pushd ~/repos/catalogue/reindexer
    python3 start_reindex.py --src=sierra --dst=reporting --mode=partial
popd
