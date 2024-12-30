#!/bin/bash

#
# Script:
#     bat
#
# Description:
#     This alias sets `bat` as a replacement for the `cat` command. `bat` supports syntax highlighting and
#     git integration, providing a better user experience for browsing and reading files in the terminal.
#
# Usage:
#     bat [OPTIONS] [FILES]
#
# Options:
#     -h, --help                Display this help and exit
#     -v, --version             Display version information and exit
#     -f, --force               Continue reading files past syntax errors
#     --paging [always|auto|never]
#                               Control when the pager is used
#     --plain                   Disable syntax highlighting
#
# Examples:
#     bat myfile.txt
#     bat myfile.txt otherfile.js
#
# Notes:
#     This alias requires `bat` to be installed on the system.
#
# Author:
#     Petr Fusek: petr.fusek97@gmail.com
#q
# Thanks to:
#     - The `bat` developers for creating a great tool.
#         - https://github.com/sharkdp/bat
#     - Chat GPT for helping me document this script! 🤖
#

unalias bat 2>/dev/null #remove potential alias
alias bat="batcat --paging=always --italic-text=always --color=always --decorations=always"
