#!/bin/bash

img_trim_all() {
    for file in *.*; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            extension="${filename##*.}"
            filename="${filename%.*}"
            convert "$file" -trim "${filename}_trimmed.${extension}"
        fi
    done
}
