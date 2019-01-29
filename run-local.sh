#!/bin/bash
# Make sure our output file exists
touch output/queries.csv

# Start logging
./bin/stream-docker-stats.sh server &
pid_server_logs=$!
./bin/stream-docker-stats.sh client &
pid_client_logs=$!

# Start the benchmark
docker-compose --log-level ERROR run --rm benchmark

# Stop logging
kill $pid_server_logs $pid_client_logs
wait $pid_server_logs $pid_client_logs 2>/dev/null

# Cleanup the server and client
docker-compose --log-level ERROR kill
docker-compose --log-level ERROR rm -f
