#!/bin/bash

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
