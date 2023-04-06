#!/bin/bash

#
# Function:
#     fzh (Fuzzy History)
#
# Description:
#     This function allows you to search through your command history interactively using fzf.
#     Once you select a command, you can either run it by pressing Enter or delete it from the history by passing the -d flag.
#
# Usage:
#     fzh [-d]
#
# Options:
#     -d        Delete the selected command from the history
#
# Dependencies:
#     This function requires fzf to be installed.
#     This function also depends on the histd function to delete commands from the history.
#
# Examples:
#     fzh
#     fzh -d
#
# Notes:
#     This function requires the following dependencies: fzf
#
# Author:
#     Petr Fusek: petr.fusek97@gmail.com
#
# Thanks to:
#     - The developers of `fzf` for creating great tool.
#         - https://github.com/junegunn/fzf
#     - Chat GPT for helping me document this script! 🤖
#

. histd.sh

unalias fzh 2>/dev/null #remove potential alias

fzh() {
    command="$(history | cut -c 8- | sort -u | fzf)"
    
    if [ -z "$command" ]; then
        return 0
    fi
    
    if [ "$1" == "-d" ]; then
        histd "$command"
    else
        ~/software/repo/wrToCmdInput/wrToCmdInput "$command"
    fi
}
