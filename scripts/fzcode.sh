#!/bin/bash

#
# Function:
#     fzcode (Fuzzy Code)
#
# Description:
#     This function allows you to search for code files in a specified directory and open them in Visual Studio Code using fzf for interactive filtering.
#     By default, the current directory is searched. You can specify a different directory as an argument.
#     The script uses ripgrep to search for files, fzf for interactive filtering, and code (Visual Studio Code) to open the selected file(s).
#     You can enable debug mode by passing the -D option. In debug mode, the search results are displayed in fzf without opening them in Visual Studio Code.
#
# Usage:
#     fzcode [OPTIONS] [DIRECTORY]
#
# Options:
#     -h, --help     Show help message
#     -D, --debug    Enable debug mode
#
# Directory:
#     The directory to search for code files in. Default is the current directory.
#
# Dependencies:
#     This function requires the following dependencies:
#     - ripgrep (rg)
#     - fzf
#     - code (Visual Studio Code)
#
# Examples:
#     fzcode ~/projects/myproject
#     fzcode -D ~/projects/myproject
#
# Notes:
#     This function requires the following dependencies: ripgrep, fzf, code.
#
# Author:
#     Petr Fusek: petr.fusek97@gmail.com
#
# Thanks to:
#     - The developers of 'ripgrep' for creating a great tool for searching files.
#         - https://github.com/BurntSushi/ripgrep
#     - The developers of 'fzf' for creating a great tool for interactive filtering.
#         - https://github.com/junegunn/fzf
#     - The developers of 'Visual Studio Code' for creating a great code editor.
#         - https://code.visualstudio.com
#     - Chat GPT for helping me document this script! 🤖
#

unalias fzcode 2>/dev/null #remove potential alias
fzcode() {
    # Parse options and arguments
    local debug=false
    local help=false
    local opts
    opts=$(getopt -o hD --long help,debug -n 'fzcode' -- "$@")
    
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
            -D|--debug)
                debug=true
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
    
    # Get the directory to search in form the first argument
    local dir="$1"
    if [ "$dir" == "" ]; then
        dir="."
    fi
    
    # Show help message if -h option is specified
    if [ "$help" == "true" ]; then
        cat <<EOF
Usage: fzcode [OPTIONS] [DIRECTORY]

Searches for code files in the specified directory and opens them in the code editor using fzf for interactive filtering.

Options:
    -h        Show this help message
    -D        Enable debug mode

Directory:
    The directory to search for code files in. Default is the current directory.

Examples:
    fzcode ~/projects/myproject
    fzcode -D ~/projects/myproject

Note:
This script requires the following dependencies:
    - ripgrep (rg)
    - fzf
    - code (Visual Studio Code)

Please make sure to install these dependencies before using the script.
EOF
        return 0
    fi
    
    # Enable debug mode if -D option is specified
    if [ "$debug" == "true" ]; then
        rg . "$dir" -n --color ansi | fzf --ansi --print0
        return 0
    fi
    
    # Search for code files in the given directory and open them in the code editor
    rg . "$dir" -n --color ansi | fzf --ansi --print0 | cut -z -d : -f 1-2 | xargs -r code -g
}
