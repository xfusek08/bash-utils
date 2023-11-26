#!/bin/bash

# Script:
#     img_png_transparent_white
#
# Description:
#     This script makes the white background transparent in PNG images and organizes the modified files in the "transparent" directory.
#
# Usage:
#     img_png_transparent_white
#
# Examples:
#     img_png_transparent_white    # makes white background transparent in PNG files and stores them in the "transparent" directory
#
# Author:
#     Petr Fusek
#     petr.fusek97@gmail.com
#
# Thanks to:
#     - Chat GPT for helping me document this script! 🤖
#

img_png_transparent_white() {
    # Create the "transparent" directory if it doesn't exist
    if [ ! -d "transparent" ]; then
        mkdir transparent
    fi
    
    # Loop through all PNG files in the current directory
    for file in *.png; do
        # Extract the filename without the extension
        filename="${file%.*}"
        
        # Make the white background transparent and move the image to the "transparent" directory
        convert "$file" -transparent white "transparent/${filename}_transparent.png"
    done
}
