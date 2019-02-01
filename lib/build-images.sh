#!/bin/bash
# Builds all required data images
echo "Building data images"

source .env
testname=$1

# Build runner
docker build --quiet --file dockerfiles/Dockerfile-runner \
    --build-arg QUERIES=$QUERIES \
    -t comunica-bencher-runner:$testname . > /dev/null

# Build server
docker build --quiet --file dockerfiles/Dockerfile-server \
    --build-arg SERVER_DATASET=$SERVER_DATASET \
    --build-arg SERVER_CONFIG=$SERVER_CONFIG \
    -t comunica-bencher-server:$testname . > /dev/null

# Build cache
docker build --quiet --file dockerfiles/Dockerfile-cache \
    -t comunica-bencher-cache:$testname . > /dev/null

# Build client
docker build --quiet --file dockerfiles/Dockerfile-client \
    --build-arg CLIENT_CONFIG=$CLIENT_CONFIG \
    --build-arg CLIENT_QUERY_SOURCES=$CLIENT_QUERY_SOURCES \
    -t comunica-bencher-client:$testname . > /dev/null
