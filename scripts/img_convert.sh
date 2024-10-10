#!/bin/bash

# Script:
#     img_convert
#
# Description:
#     This script converts images from one format to another using ImageMagick.
#     The source and target file extensions are passed as arguments, and you can choose
#     to make black or white color transparent for formats like JPG to PNG.
#
# Usage:
#     img_convert [source_extension] [target_extension] [OPTIONS]
#
# Options:
#     -b      Make black color transparent (applicable when converting to PNG).
#     -w      Make white color transparent (applicable when converting to PNG).
#
# Examples:
#     img_convert jpg png        # converts JPG images to PNG without transparency
#     img_convert png jpg        # converts PNG images to JPG
#     img_convert jpg png -b     # converts JPG to PNG and makes black color transparent
#     img_convert jpg png -w     # converts JPG to PNG and makes white color transparent
#
# Author:
#     Petr Fusek
#     petr.fusek97@gmail.com
#
# Thanks to:
#     - Chat GPT for helping me document this script! 🤖
#

. ImageMagick.sh

img_convert() {
    # Check if the correct number of arguments is provided
    if [ "$#" -lt 2 ]; then
        echo "Usage: img_convert [source_extension] [target_extension] [OPTIONS]"
        exit 1
    fi
    
    # Assign the source and target extensions
    src_ext=$1
    tgt_ext=$2
    option=$3
    
    # Create the target directory if it doesn't exist
    if [ ! -d "$tgt_ext" ]; then
        mkdir "$tgt_ext"
    fi

    # Loop through all files with the source extension
    for file in *."$src_ext"; do
        # Extract the filename without the extension
        filename="${file%.*}"

        # Get the size of the original file
        original_size=$(stat -c%s "$file")
        
        # Convert the file
        if [ "$src_ext" = "jpg" ] && [ "$tgt_ext" = "png" ]; then
            # Handle transparency options if converting from JPG to PNG
            if [ "$option" = "-b" ]; then
                # Make black color transparent
                convert "$file" -fuzz 5% -transparent black "$tgt_ext/${filename}.$tgt_ext"
            elif [ "$option" = "-w" ]; then
                # Make white color transparent
                convert "$file" -fuzz 5% -transparent white "$tgt_ext/${filename}.$tgt_ext"
            else
                # Convert without transparency
                convert "$file" "$tgt_ext/${filename}.$tgt_ext"
            fi
        else
            # General conversion for all other formats
            convert "$file" "$tgt_ext/${filename}.$tgt_ext"
        fi

        # Get the size of the converted file
        converted_size=$(stat -c%s "$tgt_ext/${filename}.$tgt_ext")
        
        # Calculate the size difference
        size_diff=$((converted_size - original_size))
        
        # Log the filename, original size, converted size, and size change
        printf "Converted %-30s | Original size: %10d bytes | Converted size: %10d bytes | Size change: %+d bytes\n" "$file" "$original_size" "$converted_size" "$size_diff"
    done
}