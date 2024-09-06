#!/bin/bash

# Script:
#     img_png_white_to_color
#
# Description:
#     This script changes the white background in PNG images to the specified color and organizes the modified files in the "colored" directory.
#
# Usage:
#     img_png_white_to_color COLOR [FUZZ]
#
# Arguments:
#     COLOR   The color to replace the white background with (e.g., "red", "#00ff00", "rgb(255,0,0)").
#     FUZZ    Optional fuzziness value to control color matching precision (default is 10%).
#
# Examples:
#     img_png_white_to_color blue              # changes white background to blue and stores the files in the "colored" directory with default fuzziness
#     img_png_white_to_color "#00ff00"         # changes white background to green and stores the files in the "colored" directory with default fuzziness
#     img_png_white_to_color "rgb(255,0,0)" 20 # changes white background to red with 20% fuzziness and stores the files in the "colored" directory
#
# Author:
#     Petr Fusek
#     petr.fusek97@gmail.com
#
# Thanks to:
#     - Chat GPT for helping me document this script! 🤖
#

. ImageMagick.sh


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
