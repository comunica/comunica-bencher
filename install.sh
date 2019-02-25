#!/bin/bash
# Installs the Comunica Bencher tool

if [ ! -d "$HOME/.comunica-bencher" ]; then
    echo "Installing Comunica Bencher"
    git clone --depth=1 --recursive https://github.com/comunica/comunica-bencher.git "$HOME/.comunica-bencher"
    dir="$HOME/.comunica-bencher"
    echo "export PATH=\"$dir/bin:\$PATH\"" >> ~/.bashrc
else
    echo "Comunica Bencher is already installed at $HOME/.comunica-bencher"
fi
