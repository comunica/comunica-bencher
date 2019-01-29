#!/bin/bash
# Continuously stream the stats of a given image into stats-<name>.csv
container_id=""
while [ "$container_id" = "" ]; do
    container_id=$(docker-compose ps -q $1 2> /dev/null)
done

echo "cpu,mem,io" > output/stats-$1.csv
while sleep 0.1; do
    ./bin/get-docker-stats.sh $container_id >> output/stats-$1.csv
done
