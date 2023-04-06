#!/bin/bash

# Define the paths to the source and build folders
SOURCE_DIR="$(pwd)/scripts"
BUILD_DIR="$(pwd)/build"

# Create the build directory if it doesn't exist
mkdir -p "$BUILD_DIR"

# Remove the build file if it exists
rm -f "$BUILD_DIR/.bash_aliases"

# Initialize the stack and seen arrays
stack=()
seen=()

# Push a file onto the stack
function push {
    # echo "trying to push $1 | ${seen[@]}"
    # If the file hasn't already been pushed onto the stack, push it now
    if ! [[ "${seen[@]}" =~ "$1" ]]; then
        # If the file has dependencies, push them onto the stack after the file itself
        dependencies=$(grep -E "^(\.|source)\s" "$SOURCE_DIR/$1" | awk '{print $2}')
        for dependency in $dependencies; do
            push "$dependency"
        done
        
        # Mark the file as seen
        seen+=("$1")
        
        # Push the file onto the stack
        stack+=("$1")
    fi
}

# Get a list of all the files in the source directory
files=$(ls "$SOURCE_DIR")

# Loop through the files and push them onto the stack
for file in $files; do
    push "$file"
done

# Loop through the stack and inline the files
for file in "${stack[@]}"; do
    echo "Inlining $file"
    
    while IFS= read -r line; do
        # Omit commented lines and source/include lines
        if [[ $line != \#* ]] && [[ $line != .* ]] && [[ $line != source* ]]; then
            echo "$line" >> "$BUILD_DIR/.bash_aliases"
        fi
    done < "$SOURCE_DIR/$file"
done
