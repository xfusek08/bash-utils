#!/bin/bash

# Script:
#     img_jpg_to_png
#
# Description:
#     This script converts JPG images to PNG format, with an option to make either black or white color transparent.
#
# Usage:
#     img_jpg_to_png [OPTIONS]
#
# Options:
#     -b      Make black color transparent. Default is white.
#
# Examples:
#     img_jpg_to_png        # converts JPG to PNG with white color transparent
#     img_jpg_to_png -b     # converts JPG to PNG with black color transparent
#
# Author:
#     Petr Fusek
#     petr.fusek97@gmail.com
#
# Thanks to:
#     - Chat GPT for helping me document this script! 🤖
#
img_jpg_to_png() {
    # Create the "png" directory if it doesn't exist
    if [ ! -d "png" ]; then
        mkdir png
    fi
    
    # Loop through all JPG files in the current directory
    for file in *.jpg; do
        # Extract the filename without the extension
        filename="${file%.*}"
        
        # Check if -b option is defined
        if [ "$1" = "-b" ]; then
            # Make black color transparent
            convert "$file" -fuzz 5% -transparent black "png/${filename}.png"
        else
            # Make white color transparent
            convert "$file" -fuzz 5% -transparent white "png/${filename}.png"
        fi
    done
}
