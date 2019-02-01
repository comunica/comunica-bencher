#!/bin/bash
# Initialize a Comunica Bencher experiment

# Validate input args
if [[ $# -ne 1 ]] ; then
    echo "Error: Missing experiment name."
    echo "  Usage: comunica-bencher init <my-experiment-name>"
    exit 1
fi
name=$1

# Make sure the target dir does not exist yet
dir="$(pwd)/$name"
if [ -d "$dir" ]; then
    echo "The target directory '$dir' already exists."
    exit 1
fi

# Copy the template folder
template_dir="$(dirname "${BASH_SOURCE[0]}")/../template"
cp -r $template_dir $dir
sed -i.bak "s/%EXPERIMENT_NAME%/$name/" $dir/.env
rm $dir/.env.bak