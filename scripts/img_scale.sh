#!/bin/bash

# Script:
#     img_scale.sh
#
# Description:
#     This script defines a function that scales a given image file by a specified factor.
#     It uses ImageMagick to resize the image, with the option to specify an output directory.
#     If no output directory is specified, the default "scaled" directory is used.
#
# Usage:
#     img_scale FILE SCALING_FACTOR [OUTPUT_DIR]
#
# Arguments:
#     FILE:            The path to the image file to be scaled.
#     SCALING_FACTOR:  The factor by which to scale the image. Must be a positive number.
#     OUTPUT_DIR:      (Optional) The directory where the scaled image will be saved. Defaults to "scaled".
#
# Examples:
#     img_scale image.jpg 0.5               # scales image.jpg by 50% and saves in "scaled" directory
#     img_scale image.png 2.0 custom_dir    # scales image.png by 200% and saves in "custom_dir"
#
# Author:
#     Petr Fusek
#     petr.fusek97@gmail.com
#
# Thanks to:
#     - Chat GPT for helping me document this script! 🤖
#

# Function to calculate scaled dimensions
calc_scaled_dims() {
    local dim="$1"
    local factor="$2"
    echo "scale=0; $dim * $factor / 1" | bc
}

# Function to scale a single image
img_scale() {
    local file="$1"
    local factor="$2"
    local output_dir="${3:-scaled}"  # Default to "scaled" if output_dir is not provided

    # Create the output directory if it doesn't exist
    mkdir -p "$output_dir"

    # Extract the filename without the extension
    local filename="${file%.*}"

    # Extract the file extension
    local extension="${file##*.}"

    # Calculate the scaled image height and width
    local height=$(calc_scaled_dims "$(identify -format "%h" "$file")" "$factor")
    local width=$(calc_scaled_dims "$(identify -format "%w" "$file")" "$factor")

    # Use ImageMagick's convert command to scale the resolution of the image
    convert -resize "${width}x${height}" "$file" "${output_dir}/${filename}_$factor.$extension"
}
