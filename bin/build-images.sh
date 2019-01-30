#!/bin/bash
source .env

# Builds all required data images
testname=$1
docker build --file dockerfiles/comunica-initialized \
    --build-arg CLIENT_CONFIG=$CLIENT_CONFIG \
    --build-arg CLIENT_QUERY_SOURCES=$CLIENT_QUERY_SOURCES \
    -t $testname-comunica-initialized .
