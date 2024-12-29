#!/bin/bash

# This is a Bash script that inlines a set of Bash script files into a single file. The script first
# defines the paths to the source and build folders, which are the folders where the script files are
# located and where the inlined file will be saved, respectively.
# Then, it creates the build directory if it doesn't exist and removes the build file if it already exists.
#
# The script initializes two arrays: stack and seen stack is used as a LIFO stack to keep track of the
# order in which the files should be inlined, and seen is used to prevent infinite recursion in case of
# circular dependencies between the files.
# The push function is used to push a file onto the stack.
# It first checks if the file has already been pushed onto the stack by searching the seen array.
# If the file has not been seen before, it pushes the file onto the stack and marks it as seen.
# If the file has dependencies, it pushes the dependencies onto the stack after the file itself.
#
# The script gets a list of all the files in the source directory and loops through the files, pushing
# them onto the stack using the push function.
# Then, it loops through the stack and inlines the files by reading each line of the file and appending
# it to the build file if it is not a commented line or a source or include line.
# Finally, the script prints a message for each file that is inlined.
#
# This script can be used to simplify the management of a large number of Bash script files by
# consolidating them into a single file.

# Define the paths to the source and build folders
SOURCE_DIR="$(pwd)/scripts"
BUILD_DIR="$(pwd)/build"

# Create the build directory if it doesn't exist
mkdir -p "$BUILD_DIR"

# Remove the build file if it exists
rm -f "$BUILD_DIR/.zsh_aliases"

# Initialize the stack and seen arrays
stack=()
seen=()

# Debug flag
DEBUG=false

# Check for the debug flag argument
if [[ "$1" == "--debug" ]]; then
    DEBUG=true
fi

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

# Initialize counters for statistics
total_source_lines=0
total_inlined_lines=0

# Loop through the stack and inline the files
for file in "${stack[@]}"; do
    # Initialize a counter for the number of inlined lines
    line_count=0
    file_lines=0
    
    while IFS= read -r line || [[ -n $line ]]; do
        ((file_lines++))
        # Omit commented lines, source/include lines, and empty lines
        if [[ ! $line =~ ^[[:space:]]*# ]] && [[ $line != .* ]] && [[ $line != source* ]] && [[ -n ${line//[[:space:]]/} ]]; then
            echo "$line" >> "$BUILD_DIR/.zsh_aliases"
            ((line_count++))
            if $DEBUG; then
                echo "🟢 Accepted: $line"
            fi
        else
            if $DEBUG; then
                echo "🔴 Rejected: $line"
            fi
        fi
    done < "$SOURCE_DIR/$file"
    
    # Update total counters
    total_source_lines=$((total_source_lines + file_lines))
    total_inlined_lines=$((total_inlined_lines + line_count))
    
    # Log inlined lines for this file in one line
    printf "Inlined %4d lines from %s\n" "$line_count" "$file"
done

# Print final statistics
echo -e "\nFinal Statistics:"
echo "Total source lines: $total_source_lines"
echo "Total inlined lines: $total_inlined_lines"
stripped_lines=$((total_source_lines - total_inlined_lines))
stripped_percent=$(awk "BEGIN {printf \"%.1f\", ($stripped_lines / $total_source_lines) * 100}")
echo "Stripped lines: $stripped_lines ($stripped_percent%)"
