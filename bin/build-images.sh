#!/bin/bash
# Builds all required data images

source .env
testname=$1

# Build server
docker build --quiet --file dockerfiles/server-initialized \
    --build-arg SERVER_DATASET=$SERVER_DATASET \
    --build-arg SERVER_CONFIG=$SERVER_CONFIG \
    -t $testname-server-initialized .

# Build cache
docker build --quiet --file dockerfiles/cache-initialized \
    -t $testname-cache-initialized .

# Build comunica client
docker build --quiet --file dockerfiles/comunica-initialized \
    --build-arg CLIENT_CONFIG=$CLIENT_CONFIG \
    --build-arg CLIENT_QUERY_SOURCES=$CLIENT_QUERY_SOURCES \
    -t $testname-comunica-initialized .
