#!/bin/bash

# Script:
#     img_png_to_jpg
#
# Description:
#     This script converts PNG images to JPG format and organizes the converted files in the "jpg" directory.
#
# Usage:
#     img_png_to_jpg
#
# Examples:
#     img_png_to_jpg    # converts PNG to JPG and stores the files in the "jpg" directory
#
# Author:
#     Petr Fusek
#     petr.fusek97@gmail.com
#
# Thanks to:
#     - Chat GPT for helping me document this script! 🤖
#

img_png_to_jpg() {
    # Create the "jpg" directory if it doesn't exist
    if [ ! -d "jpg" ]; then
        mkdir jpg
    fi
    
    # Loop through all PNG files in the current directory
    for file in *.png; do
        # Extract the filename without the extension
        filename="${file%.*}"
        
        # Convert the PNG file to JPG and move it to the "jpg" directory
        convert "$file" "jpg/${filename}.jpg"
    done
}
