#!/bin/bash

# Script:
#     img_scale_all
#
# Description:
#     This script scales the resolution of all supported image files in the current directory based on a specified scaling factor.
#
# Usage:
#     img_scale_all SCALING_FACTOR
#
# Arguments:
#     SCALING_FACTOR:   The factor by which to scale the images. Must be a positive number.
#
# Examples:
#     img_scale_all 0.5    # scales all images in the current directory by 50%
#
# Author:
#     Petr Fusek
#     petr.fusek97@gmail.com
#
# Thanks to:
#     - Chat GPT for helping me document this script! 🤖
#

. ImageMagick.sh


img_scale_all() {
    # Define function to calculate scaled image dimensions
    function calc_scaled_dims {
        local dim="$1"
        local factor="$2"
        echo "scale=0; $dim * $factor / 1" | bc
    }
    
    # Check if scaling factor is provided
    if [ -z "$1" ]; then
        echo "Please provide a scaling factor as an argument"
        return 1
    fi
    
    # Set the scaling factor
    factor="$1"
    
    # Create a directory to store the scaled images
    output_dir="scaled"
    mkdir -p "$output_dir"
    
    # Loop through all files in the current directory
    for file in *.jpg *.jpeg *.png *.gif *.bmp *.webp; do
        # Extract the filename without the extension
        filename="${file%.*}"
        
        # Extract the file extension
        extension="${file##*.}"
        
        # Calculate the scaled image height
        height=$(calc_scaled_dims "$(identify -format "%h" "$file")" "$factor")
        
        # Calculate the scaled image width
        width=$(calc_scaled_dims "$(identify -format "%w" "$file")" "$factor")
        
        # Use ImageMagick's convert command to scale the resolution of the image
        convert -resize "${width}x${height}" "$file" "${output_dir}/${filename}_$factor.$extension"
    done
}
