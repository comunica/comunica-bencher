#!/bin/bash
# Get docker stats of the given container on a single line
docker stats --no-stream $1 --format "{{.CPUPerc}},{{.MemPerc}},{{.NetIO}}"
