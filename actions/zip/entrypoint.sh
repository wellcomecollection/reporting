#!/bin/sh
set -eu

cd lambdas/sierra_varFields
zip -r sierra_varFields.zip ./*.py ./python
