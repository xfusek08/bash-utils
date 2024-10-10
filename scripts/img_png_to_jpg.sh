#!/bin/bash

#
# Alias:
#     img_png_to_jpg
#
# Description:
#     This alias converts PNG images to JPG format.
#
# Usage:
#     img_png_to_jpg
#
# Examples:
#     img_png_to_jpg    # converts PNG to JPG
#
# Author:
#     Petr Fusek
#     petr.fusek97@gmail.com
#
# Thanks to:
#     - Chat GPT for helping me document this script! 🤖
#

. ImageMagick.sh

unalias img_png_to_jpg 2>/dev/null  # Remove any existing alias
alias img_png_to_jpg='img_convert png jpg'
