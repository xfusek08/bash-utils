#!/bin/bash

# Script:
#     img_trim_all
#
# Description:
#     This script trims the transparent borders of all supported image files in the current directory and saves the trimmed images in the 'trimmed' directory.
#
# Usage:
#     img_trim_all
#
# Examples:
#     img_trim_all    # trims transparent borders of all images in the current directory and saves them in the 'trimmed' directory
#
# Author:
#     Petr Fusek
#     petr.fusek97@gmail.com
#
# Thanks to:
#     - Chat GPT for helping me document this script! 🤖
#

img_trim_all() {
    # Create the 'trimmed' directory if it doesn't exist
    if [ ! -d "trimmed" ]; then
        mkdir "trimmed"
    fi
    
    # Loop through all files in the current directory
    for file in *.jpg *.jpeg *.png *.gif *.bmp *.webp; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            extension="${filename##*.}"
            filename="${filename%.*}"
            
            # Use ImageMagick's convert command to trim the image and save it in the 'trimmed' directory
            convert "$file" -trim "trimmed/${filename}_trimmed.${extension}"
        fi
    done
}
