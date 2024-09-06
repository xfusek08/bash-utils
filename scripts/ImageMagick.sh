#!/bin/bash

alias ImageMagick='docker run --rm -v "$(pwd):/app" -w "/app" dpokidov/imagemagick'
alias convert='ImageMagick'
