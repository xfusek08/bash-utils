#!/bin/bash

#
# Script:
#     fcd (Fuzzy Change Directory)
#
# Description:
#     This scripts registers the `fcd` into current shell session.
#     The `fcd` command changes the current directory to a specified directory or to a directory selected interactively using fzf.
#
# Usage:
#     fcd [OPTIONS] [DIRECTORY]
#
# Dependencies: fzf
#
# Options:
#     -h        Show this help message
#     -a        Include hidden directories in the search
#
# Directory:
#     The directory to search for subdirectories in. Default is the current directory.
#
# Examples:
#     fcd ~/projects/myproject
#     fcd -a ~/projects/myproject
#
# Notes:
#     This script requires the following dependencies: fzf
#
# Author:
#     Petr Fusek: petr.fusek97@gmail.com
#
# Thanks to:
#     - The developers of `fzf` and `bat` for creating great tools.
#         - https://github.com/junegunn/fzf
#     - Chat GPT for helping me document this script! 🤖
#

unalias fcd 2>/dev/null #remove potential alias

fcd() {
    # Parse options and arguments
    local all=false
    local help=false
    local opts
    opts=$(getopt -o ha --long help,all -n 'fcd' -- "$@")
    
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to parse options." >&2
        return 1
    fi
    
    eval set -- "$opts"
    
    while true; do
        case "$1" in
            -h|--help)
                help=true
                shift
                ;;
            -a|--all)
                all=true
                shift
                ;;
            --)
                shift
                break
                ;;
            *)
                echo "ERROR: Invalid option $1" >&2
                return 1
                ;;
        esac
    done
    
    # Get the directory to search in from the first argument
    local dirName="$1"
    if [ "$dirName" == "" ]; then
        dirName=`pwd`
    fi
    
    # Show help message if -h option is specified
    if [ "$help" == "true" ]; then
        cat <<EOF
Usage: fcd [OPTIONS] [DIRECTORY]

Changes the current directory to the specified directory or to a directory selected interactively using fzf.

Options:
    -h        Show this help message
    -a        Include hidden directories in the search

Directory:
    The directory to search for subdirectories in. Default is the current directory.

Examples:
    fcd ~/projects/myproject
    fcd -a ~/projects/myproject

Note:
This script requires the following dependencies:
    - fzf

Please make sure to install these dependencies before using the script.
EOF
        return 0
    fi
    
    # Use find to search for directories and use fzf to select one interactively
    if [ "$all" == "false" ]; then
        local path=$(find -L "$dirName" -xdev -not -path '*/.*' 2>/dev/null | fzf)
    else
        local path=$(find -L "$dirName" -xdev 2>/dev/null | fzf)
    fi
    
    if test -f "$path"; then
        path=$(dirname "$path")
    fi
    
    # Change to the selected directory
    cd "$path"
}
