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

. img_scale.sh

img_scale_all() {
    # Check if scaling factor is provided
    if [ -z "$1" ]; then
        echo "Please provide a scaling factor as an argument"
        return 1
    fi

    # Set the scaling factor
    local factor="$1"

    # Create a directory to store the scaled images
    local output_dir="scaled"
    mkdir -p "$output_dir"

    # Supported image formats
    local image_formats=("*.jpg" "*.jpeg" "*.png" "*.gif" "*.bmp" "*.webp")

    # Loop through each image format and scale the images
    for format in "${image_formats[@]}"; do
        for file in $format; do
            # Check if the file exists before processing
            if [[ -e "$file" ]]; then
                img_scale "$file" "$factor" "$output_dir"
            fi
        done
    done
}
