#!/bin/bash

# Define alias for ImageMagick Docker image
alias ImageMagick='docker run --rm -v "$(pwd):/app" -w "/app" tigerj/imagemagick'

# Aliases for specific ImageMagick tools
alias convert='ImageMagick convert'
alias identify='ImageMagick identify'
alias mogrify='ImageMagick mogrify'
alias montage='ImageMagick montage'
alias composite='ImageMagick composite'
alias compare='ImageMagick compare'