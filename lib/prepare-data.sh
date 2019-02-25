#!/bin/bash
source .env

# Generate dataset and queries
docker run --rm -it -v $(pwd)/input/:/output comunica/watdiv -s $DATASET_SCALE -q $QUERY_COUNT

# Convert dataset to HDT
rm -f $(pwd)/input/dataset.hdt.index.v1-1
docker run --rm -it -v $(pwd)/input/:/output rdfhdt/hdt-cpp rdf2hdt /output/dataset.nt /output/dataset.hdt

# Generate HDT index file
docker run --rm -it -v $(pwd)/input/:/output rdfhdt/hdt-cpp hdtSearch /output/dataset.hdt -q 0

# Cleanup the unneeded .nt file
rm -f $(pwd)/input/dataset.nt
