#!/bin/bash

# Script:
#     img_recount
#
# Description:
#     This script renames files in the current directory, assigning them a three-digit numerical sequence, and copies them to a specified output directory.
#
# Usage:
#     img_recount [START_NUM] [OUTPUT_DIR]
#
# Arguments:
#     START_NUM:   The starting number for the file names. Defaults to 1 if not provided.
#     OUTPUT_DIR:  The output directory for the renamed files. Defaults to "./out/" if not provided.
#
# Examples:
#     img_recount                 # renames files starting from 1 and copies them to "./out/"
#     img_recount 100 ./renamed/  # renames files starting from 100 and copies them to "./renamed/"
#
# Author:
#     Petr Fusek
#     petr.fusek97@gmail.com
#
# Thanks to:
#     - Chat GPT for helping me document this script! 🤖
#

img_recount() {
    # Set the starting number for the file names. Defaults to 1 if not provided.
    count=${1:-1}
    
    # Set the output directory for the renamed files. Defaults to "./out/" if not provided.
    output_dir=${2:-./out/}
    
    # If the output directory does not exist, create it. Otherwise, remove all files in the directory.
    if [ ! -d "$output_dir" ]; then
        mkdir "$output_dir"
    else
        rm -rf "$output_dir"/*
    fi
    
    # Enable nullglob to prevent the script from iterating over the *.* pattern if there are no files that match it.
    shopt -s nullglob
    
    # Loop over all files in the current directory that have an extension and rename them.
    for file in *.*; do
        if [ -f "$file" ]; then
            # Get the file extension using parameter expansion.
            extension="${file##*.}"
            # Create a new name for the file using a three-digit numerical sequence and the original extension.
            new_name=$(printf "%03d.%s" "$count" "$extension")
            # Copy the file to the output directory and rename it.
            cp "$file" "$output_dir/$new_name"
            # Increment the count for the next file.
            count=$((count+1))
        fi
    done
}
