#!/bin/bash

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
