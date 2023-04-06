#!/bin/bash

#
# Script:
#     ask
#
# Description:
#     This script registers the `ask` function into the current shell session. The `ask` function is a simple way to ask for user input in bash scripts with optional default answers.
#
# Usage:
#     ask QUESTION [DEFAULT] [OPTIONS]
#
# Options:
#     Y       Set the default answer to "yes"
#     N       Set the default answer to "no"
#
# Examples:
#     # Ask a yes/no question with no default
#     if ask "Do you want to continue?"; then
#         echo "User answered yes."
#     else
#         echo "User answered no."
#     fi
#
#     # Ask a yes/no question with default "yes"
#     if ask "Do you want to continue?" Y; then
#         echo "User answered yes."
#     else
#         echo "User answered no."
#     fi
#
#     # Ask a yes/no question with default "no"
#     if ask "Do you want to continue?" N; then
#         echo "User answered yes."
#     else
#         echo "User answered no."
#     fi
#
# Author:
#     Dave James Miller:
#         Original source (not working): https://gist.github.com/davejamesmiller/1965569
#         New version (different then code in this file): https://github.com/d13r/dotfiles/blob/main/.bin/ask
#
# Thanks to:
#     Chat GPT for helping me document this script! 🤖
#

unalias ask 2>/dev/null #remove potential alias
ask() {
    local prompt default reply
    
    if [[ ${2:-} = 'Y' ]]; then
        prompt='Y/n'
        default='Y'
    elif [[ ${2:-} = 'N' ]]; then
        prompt='y/N'
        default='N'
    else
        prompt='y/n'
        default=''
    fi
    
    while true; do
        
        # Ask the question (not using "read -p" as it uses stderr not stdout)
        echo -n "$1 [$prompt] "
        
        # Read the answer (use /dev/tty in case stdin is redirected from somewhere else)
        read -r reply </dev/tty
        
        # Default?
        if [[ -z $reply ]]; then
            reply=$default
        fi
        
        # Check if the reply is valid
        case "$reply" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac
        
    done
}
