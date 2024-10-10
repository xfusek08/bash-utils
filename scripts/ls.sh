#!/bin/bash

#
# Alias:
#     ls
#
# Description:
#     This alias replaces the default 'ls' command with 'exa', a modern replacement for 'ls'.
#     'exa' displays files and directories in a user-friendly way with icons and color coding.
#     Directories are listed first, followed by files.
#
# Usage:
#     Type 'ls' to use the alias instead of the default 'ls' command.
#
# Options:
#     No additional options are available for this alias.
#
# Dependencies:
#     This alias requires 'exa' to be installed.
#
# Examples:
#     ls
#
# Notes:
#     This alias requires the following dependencies: exa
#
# Author:
#     Petr Fusek: petr.fusek97@gmail.com
#
# Thanks to:
#     - The developers of 'exa' for creating a great replacement for 'ls'.
#       https://github.com/ogham/exa
#     - Chat GPT for helping me document this script! 🤖
#

unalias ls 2>/dev/null  # Remove any existing alias
alias ls='exa --icons --color=auto --group-directories-first'
