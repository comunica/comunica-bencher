#!/bin/bash
source .env

# Generate dataset and queries
docker run --rm -it -v $(pwd)/input/:/output comunica/watdiv -s $DATASET_SCALE -q $QUERY_COUNT

# Convert dataset to HDT
docker run --rm -it -v $(pwd)/input/:/output rdfhdt/hdt-cpp rdf2hdt /output/dataset.nt /output/dataset.hdt

# Cleanup the unneeded .nt file
rm $(pwd)/input/dataset.nt
