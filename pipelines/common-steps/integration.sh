#!/bin/bash

source .venv/bin/activate
set -x
export BASE_URL=$1
if [ "$ENVIRONMENT" = "production" ]; then
    pytest -s test/integration/todoApiTest.py -m readonly --junitxml=result-integration.xml
else
    pytest -s test/integration/todoApiTest.py --junitxml=result-integration.xml
fi