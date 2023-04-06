#!/bin/bash

#
# Alias:
#     findNoBin
#
# Description:
#     This alias uses the `find` command to search for files in the current directory, ignoring binary files
#     and hidden directories.
#
# Usage:
#     findNoBin
#
# Examples:
#     findNoBin
#
# Author:
#     Petr Fusek: petr.fusek97@gmail.com
#
# Thanks to:
#     - Chat GPT for helping me document this script! 🤖

unalias findNoBin 2>/dev/null #remove potential alias
alias findNoBin="find . -type d -path './.*' -prune -o -type f -exec grep -Iq . {} \; -print 2>/dev/null"
