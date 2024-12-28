#!/bin/bash

#
# Script:
#     fcd (Fuzzy Change Directory)
#
# Description:
#     This scripts registers the `fcd` into current shell session.
#     The `fcd` command is a simple way to change the current directory to a directory selected interactively using fzf.
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

. find_bfs.sh

unalias fcd 2>/dev/null #remove potential alias

fcd() {
    # Parse options and arguments
    local all=false
    local prt=false
    local help=false
    local verbose=false
    local opts
    opts=$(getopt -o hapv --long help,all,print,verbose -n 'fcd' -- "$@")
    
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
            -p|--print)
                prt=true
                shift
                ;;
            -v|--verbose)
                verbose=true
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
        echo -e "$(cat <<EOF
\033[1mUsage:\033[0m fcd [OPTIONS] [DIRECTORY]

Changes the current directory to the specified directory or to a directory selected interactively using \033[1;36mfzf\033[0m.

\033[1mOptions:\033[0m
    \033[1m-h\033[0m        Show this help message
    \033[1m-a\033[0m        Include hidden directories in the search
    \033[1m-p\033[0m        Print the selected directory instead of changing to it
    \033[1m-v\033[0m        Verbose mode - print additional information

\033[1mDirectory:\033[0m
    The directory to search for subdirectories in. Default is the current directory.

\033[1mExamples:\033[0m
    fcd \033[33m~/projects/myproject\033[0m
    fcd -a \033[33m~/projects/myproject\033[0m

\033[1mNote:\033[0m
This script requires the following dependencies:
    - \033[1;36mfzf\033[0m

Please make sure to install these dependencies before using the script.
EOF
)"
        return 0
    fi
    
    # Use find to search for directories and use fzf to select one interactively
    if [ "$all" == "false" ]; then
        local path=$(set -e && set -o pipefail && find_bfs -L "$dirName" -xdev -not -path '*/.*' 2>/dev/null | fzf)
    else
        local path=$(set -e && set -o pipefail && find_bfs -L "$dirName" -xdev 2>/dev/null | fzf)
    fi
    
    # Clean the path: remove carriage returns and trailing/leading whitespace
    path=$(echo "$path" | tr -d '\r' | xargs)
    
    [ "$verbose" = true ] && echo "Extracting directory from path: $path"
    
    if test -f "$path"; then
        path=$(dirname "$path")
    fi
    
    [ "$verbose" = true ] && echo -e "\nWill navigate to $path"
    
    # Print the selected directory if -p option is specified
    if [ "$prt" == "true" ]; then
        echo "$path"
    else
        # Change to the selected directory using printf to handle special characters
        cd "$(printf '%b' "${path}")"
    fi
}
