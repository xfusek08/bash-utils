#!/bin/bash

#
# Alias:
#     img_jpg_to_png
#
# Description:
#     This alias converts JPG images to PNG format, with optional transparency for black or white colors.
#
# Usage:
#     img_jpg_to_png [OPTIONS]
#
# Options:
#     -b      Make black color transparent.
#     -w      Make white color transparent.
#     No option results in no transparency.
#
# Examples:
#     img_jpg_to_png        # converts JPG to PNG with no transparency
#     img_jpg_to_png -b     # converts JPG to PNG with black color transparent
#     img_jpg_to_png -w     # converts JPG to PNG with white color transparent
#
# Author:
#     Petr Fusek
#     petr.fusek97@gmail.com
#
# Thanks to:
#     - Chat GPT for helping me document this script! 🤖
#

. ImageMagick.sh

unalias img_jpg_to_png 2>/dev/null  # Remove any existing alias
alias img_jpg_to_png='img_convert jpg png'
