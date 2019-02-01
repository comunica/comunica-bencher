#!/bin/bash

lib_dir="$(dirname "${BASH_SOURCE[0]}")/"

# Prepare the required docker images
source .env
$lib_dir/build-images.sh $EXPERIMENT_NAME

# Make sure our output directory and file exists
mkdir -p output
touch output/queries.csv

# Start logging
$lib_dir/stream-docker-stats.sh server &
pid_server_logs=$!
$lib_dir/stream-docker-stats.sh server-cache &
pid_server_cache_logs=$!
$lib_dir/stream-docker-stats.sh client &
pid_client_logs=$!

# Start the benchmark
docker-compose --log-level ERROR run --rm benchmark

# Stop logging
kill $pid_server_logs $pid_server_cache_logs $pid_client_logs
wait $pid_server_logs $pid_server_cache_logs $pid_client_logs 2>/dev/null

# Cleanup the server and client
docker-compose --log-level ERROR kill
docker-compose --log-level ERROR rm -f