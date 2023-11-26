#!/bin/bash

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
