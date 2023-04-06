#!/bin/bash

# Define the paths to the build folder and the user's home directory
BUILD_DIR="$(pwd)/build"
HOME_DIR="$HOME"

# Copy the build file to the user's home directory
cp "$BUILD_DIR/.bash_aliases" "$HOME_DIR"

echo "Installation complete"
