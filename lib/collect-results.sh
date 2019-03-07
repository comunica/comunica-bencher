#!/bin/bash

# Get experiment name
name=$(echo ${PWD##*/} | sed "s/\//_/g")

args="matrix-values.json"
for experiment in "$@"; do
    args="$args $experiment/output $experiment/.env"
done

tar -zcf results.tar.gz $args

echo "Collected in results.tar.gz"
