#!/bin/bash

# Define the paths to the build folder and the user's home directory
BUILD_DIR="$(pwd)/build"
HOME_DIR="$HOME"
SCRIPTS_DIR="$(pwd)/home-scripts"

# Run the build script with debug flag if specified
if [[ "$1" == "--debug" ]]; then
    ./build.sh --debug
else
    ./build.sh
fi

# Copy the .bash_aliases file to the user's home directory
cp "$BUILD_DIR/.bash_aliases" "$HOME_DIR"

# Copy all files from the home-scripts directory to the user's home directory and chmod +x them
for file in "$SCRIPTS_DIR"/*; do
    cp "$file" "$HOME_DIR"
    chmod +x "$HOME_DIR/$(basename "$file")"
done

# Confirm the installation is complete
echo "Installation complete"
