#!/bin/bash
# Initialize a Comunica Bencher matrix experiment

lib_dir="$(dirname "${BASH_SOURCE[0]}")/"

# Validate input args
if [[ $# -ne 1 ]] ; then
    echo "Error: Missing experiment name."
    echo "  Usage: comunica-bencher init-matrix <my-experiment-name>"
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
template_dir="$(dirname "${BASH_SOURCE[0]}")/../template_matrix"
cp -r $template_dir $dir

# Initialize a template experiment
pushd $dir > /dev/null
$lib_dir/init.sh template
rm template/README.md
popd > /dev/null
