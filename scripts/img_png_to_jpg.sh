#!/bin/bash

img_png_to_jpg() {
    for file in *.png; do
        filename="${file%.*}"
        convert "$file" "${filename}.jpg"
    done
}
