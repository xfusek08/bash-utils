#!/bin/bash

img_png_white_to_color() {
    # Create the "colored" directory if it doesn't exist
    if [ ! -d "colored" ]; then
        mkdir colored
    fi
    
    # Set the fuzz value
    fuzz=${2:-10}
    
    # Loop through all PNG files in the current directory
    for file in *.png; do
        # Extract the filename without the extension
        filename="${file%.*}"
        
        # Change the white background to the specified color and move the image to the "colored" directory
        convert "$file" -fuzz "$fuzz%" -fill "$1" -opaque white "colored/${filename}_colored.png"
    done
}
