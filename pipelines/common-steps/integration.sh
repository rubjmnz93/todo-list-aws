#!/bin/bash

source .venv/bin/activate
set -x
export BASE_URL=$1
if [ "$ENVIRONMENT" = "production" ]; then
    pytest -s test/integration/todoApiTest.py -m readonly
else
    pytest -s test/integration/todoApiTest.py
fi