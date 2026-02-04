#!/bin/bash

source .venv/bin/activate
set -x
sam validate --region us-east-1
sam build
