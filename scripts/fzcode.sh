#!/bin/bash

#
# Function:
#     fzcode (Fuzzy Code)
#
# Description:
#     The fzcode script searches for source code files in a specified directory using ripgrep.
#     It then presents the search results to the user in a fuzzy-search interface (fzf).
#     Once the user selects a line from the search results,
#     the script opens the corresponding file in the Visual Studio Code editor.#
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
        echo -e "$(cat <<EOF
\033[1mUsage:\033[0m fzcode [OPTIONS] [DIRECTORY]

The \033[1;32mfzcode\033[0m script searches for source code files in a specified directory using \033[1;34mripgrep\033[0m.
It then presents the search results to the user in a fuzzy-search interface (\033[1;36mfzf\033[0m).
Once the user selects a line from the search results,
the script opens the corresponding file in the \033[1;35mVisual Studio Code\033[0m editor.

\033[1mOptions:\033[0m
    \033[1m-h\033[0m        Show this help message
    \033[1m-D\033[0m        Enable debug mode

\033[1mDirectory:\033[0m
    The directory to search for code files in. Default is the current directory.

\033[1mExamples:\033[0m
    fzcode \033[33m~/projects/myproject\033[0m
    fzcode -D \033[33m~/projects/myproject\033[0m

\033[1mNote:\033[0m
This script requires the following dependencies:
    - \033[1;34mripgrep\033[0m (rg)
    - \033[1;36mfzf\033[0m
    - \033[1;35mVisual Studio Code\033[0m

Please make sure to install these dependencies before using the script.
EOF
)"
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
