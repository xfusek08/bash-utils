#!/bin/bash

# Script:
#     img_find_duplicates
#
# Description:
#     This script identifies and prints the names of duplicate files in the current directory.
#     It compares files based on their names (excluding the extension) and outputs duplicates.
#
# Usage:
#     img_find_duplicates
#
# Examples:
#     img_find_duplicates    # identifies and prints the names of duplicate files in the current directory
#
# Author:
#     Petr Fusek
#     petr.fusek97@gmail.com
#
# Thanks to:
#     - Chat GPT for generating this script! 🤖
#

img_find_duplicates() {
    declare -A file_map
    for file in *; do
        # get the file name without extension
        file_name=${file%.*}
        if [[ ${file_map[$file_name]} ]]; then
            echo "$file"
        else
            file_map[$file_name]=1
        fi
    done
}
