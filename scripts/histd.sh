#!/bin/bash

# Script:
#     histd (History Delete)
#
# Description:
#     This script deletes commands from the shell history that match the given search pattern.
#
# Usage:
#     histd [OPTIONS] SEARCH_PATTERN
#
# Options:
#     None
#
# SEARCH_PATTERN:
#     A string used to match against commands in the shell history.
#
# Examples:
#     histd curl           # deletes all commands with "curl" in them
#     histd "git push -u"  # deletes all commands that match the "git push -u" pattern
#
# Author:
#     Petr Fusek: petr.fusek97@gmail.com
#
# Thanks to:
#     - Chat GPT for helping me document this script! 🤖
#

unalias histd 2>/dev/null #remove potential alias
histd() {
    to_delete=$(history | grep "$@")
    echo "This entries will be deleted from the history:"
    echo "$to_delete"
    if ask "Do you want to delete above commands?"; then
        for i in $(echo "$to_delete" | awk '{ print $1 }' | sort -r)
        do
            echo "history -d \"$i\""
            history -d "$i"
        done
    fi
    history -w
}
