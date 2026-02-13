#!/bin/bash

source .venv/bin/activate
set -x

RAD_ERRORS=$(radon cc src -nc | wc -l)

if [[ $RAD_ERRORS -ne 0 ]]
then
    echo 'Ha fallado el análisis estatico de RADON - CC'
    exit 1
fi
RAD_ERRORS=$(radon mi src -nc | wc -l)
if [[ $RAD_ERRORS -ne 0 ]]
then
    echo 'Ha fallado el análisis estatico de RADON - MI'
    exit 1
fi

flake8 src/*.py > flake8.out
if [[ $? -ne 0 ]]
then
    exit 1
fi
bandit src/*.py -o bandit.out --msg-template "{abspath}:{line}: [{test_id}] {msg}" 
if [[ $? -ne 0 ]]
then
    exit 1
fi