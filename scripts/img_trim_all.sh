#!/bin/bash

img_trim_all() {
    # Create the 'trimmed' directory if it doesn't exist
    if [ ! -d "trimmed" ]; then
        mkdir "trimmed"
    fi

    # Loop through all files in the current directory
    for file in *.*; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            extension="${filename##*.}"
            filename="${filename%.*}"

            # Use ImageMagick's convert command to trim the image and save it in the 'trimmed' directory
            convert "$file" -trim "trimmed/${filename}_trimmed.${extension}"
        fi
    done
}
