#!/bin/bash

#
# Alias:
#     lsl
#
# Description:
#     This alias provides a date-sorted file listing with newest files at the bottom.
#     Uses the standard 'ls' command with time sorting in reverse order.
#
# Usage:
#     Type 'lsl' to list files sorted by modification time (newest last).
#
# Options:
#     No additional options are available for this alias.
#
# Dependencies:
#     Uses standard 'ls' command (no additional dependencies required).
#
# Examples:
#     lsl
#
# Author:
#     Petr Fusek: petr.fusek97@gmail.com
#

. ls.sh
unalias lsl 2>/dev/null  # Remove any existing alias
alias lsl='ls -s modified -la'
