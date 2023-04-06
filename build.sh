#!/bin/bash

# Define the paths to the source and build folders
SOURCE_DIR="$(pwd)/scripts"
BUILD_DIR="$(pwd)/build"

# Create the build directory if it doesn't exist
mkdir -p "$BUILD_DIR"

# Remove the build file if it exists
rm -f "$BUILD_DIR/.bash_aliases"

# Loop through all the files in the source directory
for file in "$SOURCE_DIR"/*
do
    # Check if the file is a regular file (not a directory or a symlink)
    if [ -f "$file" ]
    then
        # Evaluate the file using the . command and append the output to the build file
        echo ". $file" >> "$BUILD_DIR/.bash_aliases"
    fi
done
