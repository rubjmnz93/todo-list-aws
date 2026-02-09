#!/bin/bash

source .venv/bin/activate
set -x
export BASE_URL=$1
pytest -s test/integration/todoApiTest.py