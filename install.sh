#!/bin/bash

# Define the paths to the build folder and the user's home directory
BUILD_DIR="$(pwd)/build"
HOME_DIR="$HOME"
SCRIPTS_DIR="$(pwd)/home-scripts"

# Run the build script
./build.sh

# Copy the .bash_aliases file to the user's home directory
cp "$BUILD_DIR/.bash_aliases" "$HOME_DIR"

# Copy all files from the home-scripts directory to the user's home directory
cp -r "$SCRIPTS_DIR/." "$HOME_DIR"

# Confirm the installation is complete
echo "Installation complete"
