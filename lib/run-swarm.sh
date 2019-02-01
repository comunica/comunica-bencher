#!/bin/bash
touch output.csv

# Prepare the required docker images
source .env
bin/build-images.sh $EXPERIMENT_NAME

docker swarm init && env $(cat .env | grep ^[A-Z] | xargs) docker stack deploy --compose-file docker-compose.yml mystack
docker stack ps mystack
read  -n 1 -p "Press any key to terminate" input
docker stack rm mystack && docker swarm leave --force

